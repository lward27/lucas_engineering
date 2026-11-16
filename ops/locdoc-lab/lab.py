#!/usr/bin/env python3
"""Bounded operator helpers for the two synthetic OMS labs; no secret output."""
import argparse
import configparser
import hashlib
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
NAMES = ['localstack', 'aws-emulator']
IMAGE = 'registry.lucas.engineering/locdoc-oms@sha256:baa39304a4200595ff68280279a1daa1ccd50833e4649fb76da4346a1fc50d0d'


def kubectl(ns, *args, **kwargs):
    if ns not in NAMES:
        raise ValueError('Unknown lab namespace')
    return subprocess.run(['kubectl', '--kubeconfig', str(Path.home()/'.kube/config'),
                           '--context', 'lucas_engineering', '--namespace', ns, *args],
                          text=True, check=True, **kwargs)


def apply(ns, body):
    data = json.dumps(body)
    kubectl(ns, 'apply', '--dry-run=server', '-f', '-', '-o', 'name', input=data)
    kubectl(ns, 'apply', '-f', '-', '-o', 'name', input=data)


def prepare(ns):
    exists = kubectl(ns, 'get', 'secret', 'oms-secrets', '--ignore-not-found', '-o', 'name',
                     capture_output=True).stdout.strip()
    if not exists:
        password = secrets.token_hex(24)
        apply(ns, {'apiVersion': 'v1', 'kind': 'Secret', 'metadata': {
            'name': 'oms-secrets', 'namespace': ns, 'labels': {'app.kubernetes.io/part-of': 'oms'}},
            'type': 'Opaque', 'stringData': {
                'postgres-password': password,
                'database-url': f'postgresql://oms:{password}@oms-postgres:5432/oms_test',
                'token-secret': secrets.token_hex(48), 'refresh-secret': secrets.token_hex(48)}})
    # The shared credentials file is consumed via credential_process. Projected
    # Secret updates are picked up without patching a GitOps Deployment.
    data = {'emulator_credentials': '[default]\naws_access_key_id = test\naws_secret_access_key = test\n'}
    if ns == 'aws-emulator':
        data['emulator_credentials'] = kubectl(ns, 'exec', 'deployment/aws-emulator', '--', 'cat',
            '/home/emulator/.aws/emulator/9297/emulator_credentials', capture_output=True).stdout
        parsed = configparser.RawConfigParser(); parsed.read_string(data['emulator_credentials'])
        assert parsed['default'].get('aws_access_key_id') and parsed['default'].get('aws_secret_access_key')
        data['ca.pem'] = kubectl(ns, 'exec', 'deployment/aws-emulator', '--', 'cat',
            '/home/emulator/.aws/emulator/9297/ca.pem', capture_output=True).stdout
    session_hash = hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()
    apply(ns, {'apiVersion': 'v1', 'kind': 'Secret', 'metadata': {
        'name': 'oms-aws-session', 'namespace': ns,
        'labels': {'app.kubernetes.io/part-of': 'oms'},
        'annotations': {'locdoc.lab/session-sha256': session_hash}},
        'type': 'Opaque', 'stringData': data})
    print(f'{ns}: lab credentials prepared; values withheld')


def terraform(ns, args):
    binary = shutil.which('terraform') or str(Path.home()/'.local/share/locdoc-dev-tools/terraform/1.13.5/terraform')
    command = [binary, '-chdir='+str(ROOT/'terraform/environments/locdoc'/ns), *args]
    env = os.environ.copy()
    if ns == 'aws-emulator':
        return subprocess.call([sys.executable, str(ROOT/'ops/aws-emulator/client.py'), *command], env=env)
    for name in list(env):
        if name.startswith('AWS_'):
            env.pop(name)
    env.update({'AWS_ACCESS_KEY_ID':'test', 'AWS_SECRET_ACCESS_KEY':'test',
                'AWS_REGION':'us-east-1', 'AWS_DEFAULT_REGION':'us-east-1',
                'AWS_ENDPOINT_URL':'http://127.0.0.1:4566', 'AWS_EC2_METADATA_DISABLED':'true',
                'AWS_CONFIG_FILE':'/dev/null', 'AWS_SHARED_CREDENTIALS_FILE':'/dev/null'})
    return subprocess.call(command, env=env)


def seed(ns):
    kubectl(ns, 'rollout', 'status', 'deployment/oms-postgres', '--timeout=180s')
    raw = kubectl(ns, 'get', 'job', 'oms-lab-initialize-v1', '--ignore-not-found', '-o', 'json',
                  capture_output=True).stdout.strip()
    if not raw:
        command = '''set -eu
cp -R /app/prisma /app/scripts /work/
cp /app/package.json /app/prisma.config.ts /work/
ln -s /app/node_modules /work/node_modules
ln -s /app/backend /work/backend
if [ -d /app/generated ]; then ln -s /app/generated /work/generated; fi
cd /work
npm run migrate:deploy:postgres
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f prisma/triggers/postgres/install.sql
npm run seed:synthetic -- --allow-target=oms_test
'''
        body = {'apiVersion':'batch/v1','kind':'Job','metadata':{'name':'oms-lab-initialize-v1','namespace':ns},
            'spec':{'backoffLimit':0,'activeDeadlineSeconds':600,'template':{
                'metadata':{'labels':{'app.kubernetes.io/part-of':'oms'}},
                'spec':{'restartPolicy':'Never','automountServiceAccountToken':False,
                    'securityContext':{'runAsNonRoot':True,'runAsUser':1000,'runAsGroup':1000,'fsGroup':1000,
                                       'seccompProfile':{'type':'RuntimeDefault'}},
                    'containers':[{'name':'initialize','image':IMAGE,'command':['sh','-ec',command],
                        'env':[{'name':'DATABASE_PROVIDER','value':'postgres'},{'name':'NODE_ENV','value':'development'},
                               {'name':'ENV_TYPE','value':'development'}, {'name':'HOME','value':'/tmp'},
                               {'name':'NPM_CONFIG_CACHE','value':'/tmp/npm'},
                               {'name':'DATABASE_URL','valueFrom':{'secretKeyRef':{'name':'oms-secrets','key':'database-url'}}}],
                        'securityContext':{'allowPrivilegeEscalation':False,'capabilities':{'drop':['ALL']}},
                        'resources':{'requests':{'cpu':'100m','memory':'512Mi'},'limits':{'memory':'2Gi'}},
                        'volumeMounts':[{'name':'work','mountPath':'/work'},{'name':'tmp','mountPath':'/tmp'}]}],
                    'volumes':[{'name':'work','emptyDir':{'sizeLimit':'512Mi'}},{'name':'tmp','emptyDir':{'sizeLimit':'128Mi'}}]}}}}
        apply(ns, body)
    elif any(c['type']=='Failed' and c['status']=='True' for c in json.loads(raw).get('status',{}).get('conditions',[])):
        raise RuntimeError('Existing initialization Job failed; inspect it before choosing a new operation')
    kubectl(ns, 'wait', '--for=condition=complete', 'job/oms-lab-initialize-v1', '--timeout=600s')
    for name in ['seed-mock-email.sql','seed-mock-payment.sql','seed-mock-seclock.sql','seed-workflow-examples.sql']:
        kubectl(ns, 'exec', '-i', 'deployment/oms-postgres', '--', 'psql', '-U', 'oms', '-d', 'oms_test',
                '-v', 'ON_ERROR_STOP=1', '-X', input=(ROOT/'ops/locdoc'/name).read_text())
    print(f'{ns}: guarded synthetic fixtures initialized')


def smoke(ns):
    kubectl(ns, 'exec', '-i', 'deployment/oms', '-c', 'oms', '--',
            'node', '--input-type=module', input=(ROOT/'ops/locdoc-lab/oms-smoke.mjs').read_text(),
            timeout=120)


def database_smoke(ns):
    address = kubectl(ns, 'get', 'service', 'oms-postgres', '-o', 'jsonpath={.spec.clusterIP}', capture_output=True).stdout
    kubectl(ns, 'exec', '-i', 'deployment/oms', '-c', 'oms', '--', 'env', 'OMS_TEST_DB_IP='+address,
            'node', '--input-type=module', input=(ROOT/'ops/locdoc-lab/database-smoke.mjs').read_text(), timeout=120)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('action',choices=['prepare','terraform','seed','forward','smoke','database-smoke'])
    p.add_argument('environment',choices=NAMES)
    p.add_argument('args',nargs=argparse.REMAINDER)
    a=p.parse_args(); args=a.args[1:] if a.args[:1]==['--'] else a.args
    if a.action=='prepare':prepare(a.environment)
    elif a.action=='terraform':return terraform(a.environment,args)
    elif a.action=='seed':seed(a.environment)
    elif a.action=='smoke':smoke(a.environment)
    elif a.action=='database-smoke':database_smoke(a.environment)
    else:
        port='8081' if a.environment=='localstack' else '8082'
        kubectl(a.environment,'port-forward','--address','127.0.0.1','service/oms',port+':8080')
    return 0


if __name__=='__main__':
    raise SystemExit(main())
