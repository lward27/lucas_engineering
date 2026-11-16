#!/usr/bin/env python3
"""Build a verified private OMS commit using the existing remote-buildkit Task.

No Git credential is sent to the cluster. No workload is restarted. Inspect the
printed preview; use --execute only for an authorized source/image build.
"""
import argparse, hashlib, json, re, subprocess, time
from pathlib import Path

K=['kubectl','--kubeconfig',str(Path.home()/'.kube/config'),'--context','lucas_engineering','-n','tekton-pipelines']
def cmd(args, **kw):return subprocess.run(args,check=True,**kw)
def git(repo,*args):return subprocess.check_output(['git','-C',str(repo),*args],text=True).strip()
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('repo',type=Path);p.add_argument('--branch',required=True);p.add_argument('--revision',required=True)
 p.add_argument('--attempt',type=int,default=1);p.add_argument('--provider',choices=['mysql','postgres'],required=True);p.add_argument('--execute',action='store_true')
 a=p.parse_args();repo=a.repo.resolve();revision=a.revision
 if not re.fullmatch('[0-9a-f]{40}',revision):raise SystemExit('Full commit SHA required')
 if git(repo,'status','--porcelain'):raise SystemExit('Clean source worktree required')
 cmd(['git','-C',str(repo),'fetch','--quiet','origin',f'refs/heads/{a.branch}'])
 remote=git(repo,'ls-remote','--exit-code','origin',f'refs/heads/{a.branch}').split()[0]
 if remote!=revision or git(repo,'rev-parse','HEAD')!=revision:raise SystemExit('Source/remote revision mismatch')
 archive=subprocess.check_output(['git','-C',str(repo),'archive','--format=tar',revision])
 archive_sha=hashlib.sha256(archive).hexdigest();epoch=git(repo,'show','-s','--format=%ct',revision)
 name=f'oms-{a.provider}-{revision[:12]}-a{a.attempt}'
 image=f'registry.lucas.engineering/locdoc-oms:git-{revision}-{a.provider}'
 pvc={'apiVersion':'v1','kind':'PersistentVolumeClaim','metadata':{'name':name},'spec':{'accessModes':['ReadWriteOnce'],'storageClassName':'local-path','resources':{'requests':{'storage':'3Gi'}}}}
 pod={'apiVersion':'v1','kind':'Pod','metadata':{'name':name+'-source','labels':{'app.kubernetes.io/part-of':'locdoc-build'}},'spec':{'nodeSelector':{'workload':'build'},'tolerations':[{'key':'workload','operator':'Equal','value':'build','effect':'NoSchedule'}],'automountServiceAccountToken':False,'restartPolicy':'Never','activeDeadlineSeconds':600,'securityContext':{'runAsNonRoot':True,'runAsUser':1000,'runAsGroup':1000,'fsGroup':1000,'seccompProfile':{'type':'RuntimeDefault'}},'containers':[{'name':'stage','image':'alpine@sha256:d9e853e87e55526f6b2917df91a2115c36dd7c696a35be12163d44e6e2a4b6bc','command':['sh','-ec','until test -f /source/.ready; do sleep 2; done'],'resources':{'requests':{'cpu':'25m','memory':'32Mi'},'limits':{'memory':'128Mi'}},'securityContext':{'allowPrivilegeEscalation':False,'readOnlyRootFilesystem':True,'capabilities':{'drop':['ALL']}},'volumeMounts':[{'name':'source','mountPath':'/source'},{'name':'tmp','mountPath':'/tmp'}]}],'volumes':[{'name':'source','persistentVolumeClaim':{'claimName':name}},{'name':'tmp','emptyDir':{'sizeLimit':'512Mi'}}]}}
 run={'apiVersion':'tekton.dev/v1','kind':'TaskRun','metadata':{'name':name,'labels':{'app.kubernetes.io/part-of':'locdoc-build'},'annotations':{'locdoc/source-commit':revision,'locdoc/source-archive-sha256':archive_sha}},'spec':{'taskRef':{'name':'remote-buildkit'},'serviceAccountName':'tekton-ci-build','timeout':'40m','podTemplate':{'automountServiceAccountToken':False,'nodeSelector':{'workload':'build'},'tolerations':[{'key':'workload','operator':'Equal','value':'build','effect':'NoSchedule'}]},'params':[{'name':'IMAGE','value':image},{'name':'DOCKERFILE','value':'Dockerfile.production'},{'name':'CONTEXT','value':'.'},{'name':'BUILD_ARGS','value':['SOURCE_REVISION='+revision,'SOURCE_DATE_EPOCH='+epoch,'DATABASE_PROVIDER='+a.provider]}],'workspaces':[{'name':'source','persistentVolumeClaim':{'claimName':name}}]}}
 record={'source_repository':git(repo,'remote','get-url','origin'),'source_commit':revision,'source_archive_sha256':archive_sha,'platform':'linux/amd64','image':image,'taskrun':name,'workspace':name,'source_pod':name+'-source'}
 print(json.dumps(record,indent=2),flush=True)
 for resource in [pvc,pod,run]:cmd(K+['create','--dry-run=server','-f','-','-o','name'],input=json.dumps(resource),text=True)
 if not a.execute:return
 # Recheck immediately before any effect. Named operation resources prevent silent replay.
 if git(repo,'ls-remote','--exit-code','origin',f'refs/heads/{a.branch}').split()[0]!=revision:raise SystemExit('Remote branch moved')
 runtime=Path(__file__).resolve().parent/'.runtime';runtime.mkdir(exist_ok=True,mode=0o700)
 receipt=runtime/(name+'.json')
 if receipt.exists():raise SystemExit('Operation already recorded; reconcile existing TaskRun instead of replaying')
 receipt.write_text(json.dumps(record,indent=2)+'\n');receipt.chmod(0o600)
 for resource in [pvc,pod]:cmd(K+['create','-f','-','-o','name'],input=json.dumps(resource),text=True)
 cmd(K+['wait','--for=condition=Ready','pod/'+name+'-source','--timeout=180s'])
 stage=f'cat > /tmp/source.tar; echo "{archive_sha}  /tmp/source.tar" | sha256sum -c -; tar -xf /tmp/source.tar -C /source; rm /tmp/source.tar; touch /source/.ready'
 cmd(K+['exec','-i',name+'-source','-c','stage','--','sh','-ec',stage],input=archive)
 cmd(K+['create','-f','-','-o','name'],input=json.dumps(run),text=True)
 print('Created '+name+'; inspect TaskRun status/results, not credential-bearing build logs.',flush=True)
if __name__=='__main__':main()
