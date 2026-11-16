"""Render the real overlays: catch patch-order and private TLS boundary regressions."""
import json
from pathlib import Path
import subprocess
import unittest

ROOT=Path(__file__).resolve().parents[3]
class ManifestTests(unittest.TestCase):
    def test_runtime_and_database_boundaries_in_both_overlays(self):
        import yaml
        release=json.loads((ROOT/'ops/locdoc-lab/RELEASE.json').read_text())
        for namespace in ('localstack','aws-emulator'):
            with self.subTest(namespace=namespace):
                raw=subprocess.check_output(['kubectl','kustomize',str(ROOT/'environments/locdoc'/namespace)],text=True)
                docs=list(yaml.safe_load_all(raw));self.assertTrue(all(d['metadata']['namespace']==namespace for d in docs))
                app=next(d for d in docs if d['kind']=='Deployment' and d['metadata']['name']=='oms')['spec']['template']['spec']
                runtime=next(c for c in app['containers'] if c['name']=='oms')
                self.assertEqual(runtime['image'],release['image']);self.assertTrue(runtime['securityContext']['readOnlyRootFilesystem'])
                self.assertEqual(app['securityContext']['runAsUser'],1000)
                fixture=next(c for c in app['initContainers'] if c['name']=='database-fixtures')
                self.assertTrue(fixture['image'].startswith('postgres@sha256:'),'psql init must not inherit the production app image')
                settings={e['name']:e.get('value') for e in fixture['env']}
                self.assertEqual(settings['PGSSLMODE'],'verify-full');self.assertEqual(settings['PGSSLROOTCERT'],'/database-tls/ca.pem')
                ca=next(v for v in app['volumes'] if v['name']=='database-ca')
                self.assertEqual(ca['secret']['items'],[{'key':'tls.crt','path':'ca.pem'}])
                self.assertTrue({'/tmp','/app/uploads','/app/dist/logs','/database-tls'}.issubset({m['mountPath'] for m in runtime['volumeMounts']}))
                db=next(d for d in docs if d['kind']=='Deployment' and d['metadata']['name']=='oms-postgres')['spec']['template']['spec']
                key=next(v for v in db['volumes'] if v['name']=='database-tls');self.assertEqual(key['secret']['defaultMode'],0o440)
                hba=next(d for d in docs if d['kind']=='ConfigMap' and d['metadata']['name']=='oms-db-hba')['data']['pg_hba.conf']
                self.assertIn('hostnossl all all 0.0.0.0/0 reject',hba);self.assertIn('hostssl all all 0.0.0.0/0 scram-sha-256',hba)
if __name__=='__main__':unittest.main()
