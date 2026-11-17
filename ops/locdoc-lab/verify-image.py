#!/usr/bin/env python3
"""Verify a successful OMS build through the maintained registry TLS reader."""
import argparse, hashlib, io, json, re, sys, tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/cluster-ops'))
from lib.common import Profile
from lib.connections import registry_read

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('taskrun');p.add_argument('--expected-source',required=True);p.add_argument('--provider',choices=['postgres','mysql'],required=True);p.add_argument('--output',type=Path)
 a=p.parse_args()
 if not re.fullmatch('[0-9a-f]{40}',a.expected_source):raise SystemExit('Full expected source SHA required')
 if a.output and a.output.exists():raise SystemExit('Output already exists; preserve the original receipt')
 profile=Profile(ROOT/'tools/cluster-ops/profiles/lucas_engineering.json');profile.verify()
 run=json.loads(profile.kubectl(['get','taskrun',a.taskrun,'-o','json'],namespace='tekton-pipelines'))
 assert any(c['type']=='Succeeded' and c['status']=='True' for c in run['status']['conditions'])
 assert run['metadata']['annotations']['locdoc/source-commit']==a.expected_source
 results={r['name']:r['value'] for r in run['status']['results']};digest=results['IMAGE_DIGEST'];assert re.fullmatch('sha256:[0-9a-f]{64}',digest)
 assert results['IMAGE_URL'].startswith('registry.lucas.engineering/locdoc-oms:')
 def get(kind,digest):
  raw=registry_read(profile,'locdoc-oms',kind+'/'+digest,accept='application/vnd.oci.image.manifest.v1+json, application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.v2+json')[0]
  assert 'sha256:'+hashlib.sha256(raw).hexdigest()==digest
  return raw
 task_digest=digest;manifest=json.loads(get('manifests',digest))
 if 'manifests' in manifest:
  digest=next(x['digest'] for x in manifest['manifests'] if x.get('platform',{}).get('os')=='linux' and x.get('platform',{}).get('architecture')=='amd64');manifest=json.loads(get('manifests',digest))
 config=json.loads(get('blobs',manifest['config']['digest']));labels=config['config']['Labels']
 assert config['os']=='linux' and config['architecture']=='amd64' and config['config']['User']=='1000:1000'
 assert labels['org.opencontainers.image.revision']==a.expected_source
 assert labels['org.opencontainers.image.source']=='https://github.com/Daniel-Maloney/LocDoc_OMS3'
 assert labels['engineering.locdoc.database-provider']==a.provider
 layer_index=-1;dist_layer=None
 for history in config['history']:
  if history.get('empty_layer'):continue
  layer_index+=1
  if 'COPY /app/dist ./dist' in history.get('created_by',''):dist_layer=manifest['layers'][layer_index]
 assert dist_layer and dist_layer['size']<8*1024*1024,'Bounded compiled-code layer required'
 with tarfile.open(fileobj=io.BytesIO(get('blobs',dist_layer['digest'])),mode='r:*') as archive:
  stripe=next(m for m in archive.getmembers() if m.name.endswith('dist/routes/stripe.js'))
  code=archive.extractfile(stripe).read().decode()
  assert not re.search(r'sk_(?:live|test)_[A-Za-z0-9]{24,}',code),'Unexpected inline Stripe credential in compiled route'
  assert any(m.name.endswith('dist/routes/documents.js') for m in archive.getmembers())
 record={'source_commit':a.expected_source,'source_archive_sha256':run['metadata']['annotations']['locdoc/source-archive-sha256'],'taskrun':a.taskrun,'image':'registry.lucas.engineering/locdoc-oms@'+digest,'task_digest':task_digest,'platform':'linux/amd64','user':config['config']['User'],'labels':labels,'compiled_route_credential_check':'passed','private_document_route_present':True,'compressed_bytes':sum(x['size'] for x in manifest['layers'])}
 text=json.dumps(record,indent=2)+'\n'
 if a.output:
  with a.output.open('x') as file:file.write(text)
 print(text,end='')
if __name__=='__main__':main()
