#!/usr/bin/env python3
"""Run verified MySQL TLS positive/negative checks in a disposable local fixture.

Uses only generated one-day test certificates and fixed synthetic credentials.
Does not connect to either Kubernetes database or any AWS account.
"""
import argparse, json, os, subprocess, tempfile, time
from pathlib import Path
def run(args,**kw):return subprocess.run(args,check=True,**kw)
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('repo',type=Path);args=parser.parse_args();repo=args.repo.resolve()
 name='locdoc-mysql-tls-'+str(os.getpid())
 image='mysql@sha256:a81d043930e51745522bd5c430961cf8286f0a23f0a9a2a6e0108f7ea71b0902'
 with tempfile.TemporaryDirectory(prefix='locdoc-mysql-tls-') as raw:
  root=Path(raw);root.chmod(0o700)
  for command in [
   ['req','-x509','-newkey','rsa:2048','-nodes','-days','1','-subj','/CN=OMS disposable test CA','-keyout','ca.key','-out','ca.pem'],
   ['req','-newkey','rsa:2048','-nodes','-subj','/CN=localhost','-keyout','tls.key','-out','tls.csr'],
  ]:run(['openssl',*command],cwd=root,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  (root/'extensions').write_text('subjectAltName=DNS:localhost\nextendedKeyUsage=serverAuth\n')
  run(['openssl','x509','-req','-in','tls.csr','-CA','ca.pem','-CAkey','ca.key','-CAcreateserial','-out','tls.crt','-days','1','-extfile','extensions'],cwd=root,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  try:
   run(['docker','create','--name',name,'--user','0','--entrypoint','sh','-p','127.0.0.1::3306','-e','MYSQL_ROOT_PASSWORD=fixture-only-root','-e','MYSQL_DATABASE=oms','-e','MYSQL_USER=oms','-e','MYSQL_PASSWORD=fixture-only-password',image,'-ec','chown -R 999:999 /tls; chmod 700 /tls; chmod 600 /tls/tls.key; exec docker-entrypoint.sh mysqld --ssl-ca=/tls/ca.pem --ssl-cert=/tls/tls.crt --ssl-key=/tls/tls.key --require-secure-transport=ON'],stdout=subprocess.DEVNULL)
   run(['docker','cp',str(root),name+':/tls'],stdout=subprocess.DEVNULL)
   run(['docker','start',name],stdout=subprocess.DEVNULL)
   inspect=json.loads(subprocess.check_output(['docker','inspect',name]))[0]
   port=inspect['NetworkSettings']['Ports']['3306/tcp'][0]['HostPort']
   env={**os.environ,'OMS_TLS_PORT':port,'OMS_TLS_CA':str(root/'ca.pem'),'OMS_TLS_REPO':str(repo)}
   script=r'''
const {createRequire}=await import('node:module');const {pathToFileURL}=await import('node:url');const assert=(await import('node:assert/strict')).default;
const require=createRequire(process.env.OMS_TLS_REPO+'/package.json');const mariadb=require('mariadb');
const {databaseTls}=await import(pathToFileURL(process.env.OMS_TLS_REPO+'/dist/utils/databaseTls.js'));
process.env.NODE_ENV='production';process.env.ENV_TYPE='production';process.env.DB_SSL_MODE='verify-full';process.env.DB_SSL_ROOT_CERT=process.env.OMS_TLS_CA;
const options={host:'localhost',port:Number(process.env.OMS_TLS_PORT),user:'oms',password:'fixture-only-password',database:'oms',connectTimeout:3000};
const ssl=databaseTls('mysql://localhost/oms').ssl;
let ready=false;
for(let attempt=0;attempt<60;attempt++){let c;try{c=await mariadb.createConnection({...options,ssl});ready=true;break;}catch{await new Promise(r=>setTimeout(r,1000));}finally{await c?.end();}}
assert.ok(ready,'TLS fixture did not become ready');
const c=await mariadb.createConnection({...options,ssl});const result=await c.query("SHOW SESSION STATUS LIKE 'Ssl_cipher'");assert.ok(result[0].Value);await c.end();
async function denied(config,pattern){let c;try{c=await mariadb.createConnection(config);assert.fail('Invalid TLS configuration connected');}catch(error){assert.match(String(error.message),pattern);}finally{await c?.end();}}
await denied({...options,ssl:{...ssl,ca:require('node:fs').readFileSync(process.env.OMS_TLS_REPO+'/build/certs/rds-ca.pem','utf8')}},/certificate|self.signed|verify/i);
await denied({...options,host:'127.0.0.1',ssl},/altname|hostname|IP.*match|certificate.*name/i);
await denied({...options,ssl:false},/insecure|secure.transport|SSL|TLS/i);
console.log(JSON.stringify({mysql_tls:'verified',invalid_ca:'rejected',wrong_hostname:'rejected',plaintext:'rejected'}));
'''
   run(['node','--input-type=module','-'],input=script,text=True,env=env,timeout=100)
  finally:
   subprocess.run(['docker','rm','--force','--volumes',name],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
if __name__=='__main__':main()
