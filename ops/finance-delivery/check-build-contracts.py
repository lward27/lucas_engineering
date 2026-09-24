#!/usr/bin/env python3
"""Render Finance build contracts and exercise their real guard scripts locally."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
rendered = subprocess.check_output([
    'helm', 'template', 'tekton-ci', str(ROOT / 'charts/tekton-ci'),
    '--namespace', 'tekton-pipelines',
], text=True)
documents = json.loads(subprocess.check_output([
    'ruby', '-ryaml', '-rjson', '-e',
    'puts JSON.generate(YAML.load_stream(STDIN.read))',
], input=rendered, text=True))
resources = {(d['kind'], d['metadata']['name']): d for d in documents if d}
checks = []

def check(name, condition):
    assert condition, name
    checks.append(name)


def shell(script, variables):
    return subprocess.run(['bash', '-c', script],
                          env={'PATH': os.defpath, **variables},
                          capture_output=True, text=True).returncode


for name, repo in [('pharness-yfinance-build', 'yfinance_wrapper'),
                   ('pharness-finance-frontend-build', 'finance-frontend')]:
    spec = resources[('Pipeline', name)]['spec']
    tasks = {task['name']: task for task in spec['tasks']}
    check(name + ': three required results', {r['name'] for r in spec['results']} == {'SOURCE_COMMIT', 'IMAGE_URL', 'IMAGE_DIGEST'})
    check(name + ': fixed source repository', next(p['value'] for p in tasks['fetch-source']['params'] if p['name'] == 'url') == 'https://github.com/lward27/' + repo + '.git')
    check(name + ': no deployment task', set(tasks) == {'validate-revision', 'fetch-source', 'verify-checkout', 'build-push'})
    clone = {p['name']: p['value'] for p in tasks['fetch-source']['params']}
    check(name + ': quiet clone with verified TLS', clone['verbose'] == 'false' and clone['sslVerify'] == 'true')
    params = {p['name']: p['value'] for p in tasks['build-push']['params']}
    check(name + ': immutable image and source label input', params['IMAGE'] == 'registry.lucas.engineering/' + repo + ':git-$(params.revision)' and params['RESULT_IMAGE_URL'] == params['IMAGE'] and params['BUILD_ARGS'] == ['SOURCE_COMMIT=$(params.revision)'])
    script = tasks['validate-revision']['taskSpec']['steps'][0]['script']
    for label, value, valid in [('sha', 'a' * 40, True), ('branch', 'main', False),
                               ('short', 'a' * 39, False), ('uppercase', 'A' * 40, False),
                               ('not-hex', 'g' * 40, False), ('shell-text', '$(exit 0)', False)]:
        check(name + ': revision ' + label, (shell(script, {'REVISION': value}) == 0) == valid)
    script = tasks['verify-checkout']['taskSpec']['steps'][0]['script']
    for match in [True, False]:
        check(name + ': checkout match ' + str(match), (shell(script, {'REQUESTED': 'a' * 40, 'RESOLVED': ('a' if match else 'b') * 40}) == 0) == match)

publisher = resources[('Task', 'remote-buildkit')]['spec']['steps'][1]['script']
with tempfile.TemporaryDirectory(prefix='astra-finance-contract-') as directory:
    root = Path(directory)
    script = publisher.replace('/var/run/buildkit-metadata/image.json', str(root / 'metadata.json')).replace('$(results.IMAGE_DIGEST.path)', str(root / 'digest')).replace('$(results.IMAGE_URL.path)', str(root / 'image'))
    for label, digest, valid in [('sha256', 'sha256:' + 'a' * 64, True), ('missing-prefix', 'a' * 64, False), ('short', 'sha256:abc', False), ('uppercase', 'sha256:' + 'A' * 64, False), ('missing', '', False)]:
        (root / 'metadata.json').write_text(json.dumps({'containerimage.digest': digest}))
        result = shell(script, {'IMAGE': 'registry.test/finance:git-' + 'a' * 40, 'RESULT_IMAGE_URL': '', 'BUILD_TARGET': ''})
        check('BuildKit result ' + label, (result == 0) == valid)
        if valid:
            check('BuildKit exact result preserved', (root / 'digest').read_text() == digest and (root / 'image').read_text() == 'registry.test/finance:git-' + 'a' * 40)

builder = resources[('Deployment', 'k3s-buildkit')]['spec']
builder_pod = builder['template']['spec']
builder_container = builder_pod['containers'][0]
check('BuildKit daemon is pinned to the released rootless image', builder_container['image'] == 'docker.io/moby/buildkit@sha256:80b15f0735e87bab7bf59ec4d695dfb4a7cfb25521cf56dc75d6f256285b63ef')
check('BuildKit lifecycle probes use its configured TCP listener', all(builder_container[name].get('tcpSocket') == {'port': 'buildkit'} and 'exec' not in builder_container[name] for name in ['startupProbe', 'readinessProbe', 'livenessProbe']))
check('BuildKit daemon selects the dedicated AMD64 build node', builder_pod['nodeSelector'] == {'kubernetes.io/arch': 'amd64', 'workload': 'build'})
check('BuildKit daemon tolerates only the build-node taint', builder_pod['tolerations'] == [{'key': 'workload', 'operator': 'Equal', 'value': 'build', 'effect': 'NoSchedule'}])
check('BuildKit daemon runs rootless without host access', builder_pod['securityContext']['runAsUser'] == 1000 and builder_pod['securityContext']['runAsNonRoot'] is True and not builder_pod.get('hostNetwork') and not any(v.get('hostPath') for v in builder_pod.get('volumes', [])) and builder_container['securityContext'].get('privileged') is not True)
check('BuildKit daemon has no Kubernetes API token', builder_pod['automountServiceAccountToken'] is False and resources[('ServiceAccount', 'k3s-buildkit')]['automountServiceAccountToken'] is False)
build_sa = resources[('ServiceAccount', 'tekton-ci-build')]
check('Build-only TaskRuns have a no-token identity with no chart RBAC binding', build_sa['automountServiceAccountToken'] is False and not any(subject.get('name') == 'tekton-ci-build' for (kind, _), resource in resources.items() if kind in ['RoleBinding', 'ClusterRoleBinding'] for subject in resource.get('subjects', [])))
check('BuildKit uses a bounded persistent cache', resources[('PersistentVolumeClaim', 'k3s-buildkit-cache')]['spec']['resources']['requests']['storage'] == '60Gi' and any(v.get('persistentVolumeClaim', {}).get('claimName') == 'k3s-buildkit-cache' for v in builder_pod['volumes']))
service = resources[('Service', 'k3s-buildkit')]['spec']
check('BuildKit service selects only the in-cluster daemon', service['selector'] == builder['selector']['matchLabels'] and service['ports'][0]['port'] == 12340)
check('Static external BuildKit endpoint is removed', ('EndpointSlice', 'k3s-buildkit-ipv4') not in resources)
policy = resources[('NetworkPolicy', 'k3s-buildkit-isolation')]['spec']
check('BuildKit ingress is limited to its Tekton Task clients', policy['ingress'][0]['from'][0]['podSelector']['matchLabels'] == {'tekton.dev/task': 'remote-buildkit'} and policy['ingress'][0]['ports'] == [{'protocol': 'TCP', 'port': 12340}] and policy['policyTypes'] == ['Ingress', 'Egress'])
check('BuildKit egress allows only its registry gateway, DNS and public web', len(policy['egress']) == 3 and policy['egress'][0]['to'][0]['namespaceSelector']['matchLabels']['kubernetes.io/metadata.name'] == 'registry' and policy['egress'][0]['to'][0]['podSelector']['matchLabels'] == {'app.kubernetes.io/name': 'registry-write-gateway'} and policy['egress'][1]['to'][0]['podSelector']['matchLabels'] == {'k8s-app': 'kube-dns'} and policy['egress'][2]['to'][0]['ipBlock']['except'] == ['10.0.0.0/8', '100.64.0.0/10', '127.0.0.0/8', '169.254.0.0/16', '172.16.0.0/12', '192.168.0.0/16'] and policy['egress'][2]['ports'] == [{'protocol': 'TCP', 'port': 80}, {'protocol': 'TCP', 'port': 443}])
buildkitd_config = resources[('ConfigMap', 'k3s-buildkit')]['data']['buildkitd.toml']
check('BuildKit worker is rootless and writes registry traffic through the private gateway', 'rootless = true' in buildkitd_config and 'registry-write-gateway.registry.svc.cluster.local:8443' in buildkitd_config and 'registry.lucas.engineering' not in buildkitd_config)
task = resources[('Task', 'remote-buildkit')]['spec']
client_script = task['steps'][0]['args'][0]
check('BuildKit client script has valid shell syntax', subprocess.run(['sh', '-n'], input=client_script, text=True, capture_output=True).returncode == 0)
check('Tekton client uses in-cluster mTLS and private registry output', task['volumes'][0]['secret']['secretName'] == 'k3s-buildkit-client-tls' and '--tlsservername k3s-buildkit.tekton-pipelines.svc.cluster.local' in client_script and 'registry-write-gateway.registry.svc.cluster.local:8443/$image_path' in client_script and 'destination must use registry.lucas.engineering' in client_script and 'unsafe destination path' in client_script)
check('BuildKit Task exposes a safe optional stage target', next(p for p in task['params'] if p['name'] == 'BUILD_TARGET')['default'] == '' and 'target=$BUILD_TARGET' in client_script and 'invalid Dockerfile target' in client_script)
target_guard = 'case "$BUILD_TARGET" in' + client_script.split('case "$BUILD_TARGET" in', 1)[1].split('source_root=', 1)[0]
for target, valid in [('', True), ('runtime', True), ('bundle', True), ('bad;echo', False), ('../escape', False), ('9stage', False)]:
    check('BuildKit Dockerfile target guard ' + (target or 'default'), (shell(target_guard, {'BUILD_TARGET': target}) == 0) == valid)
generic_pipeline = resources[('Pipeline', 'clone-build-push')]['spec']
check('Generic PHarness build Pipeline forwards its optional Dockerfile target', next(p for p in generic_pipeline['params'] if p['name'] == 'build-target')['default'] == '' and any(p['name'] == 'BUILD_TARGET' and p['value'] == '$(params.build-target)' for p in next(t for t in generic_pipeline['tasks'] if t['name'] == 'build-push')['params']))
check('BuildKit client preserves public immutable image result', 'image="$RESULT_IMAGE_URL"' in task['steps'][1]['script'] and 'image="$IMAGE"' in task['steps'][1]['script'])
check('BuildKit server certificate covers its Service DNS name', 'k3s-buildkit.tekton-pipelines.svc.cluster.local' in resources[('Certificate', 'k3s-buildkit-server')]['spec']['dnsNames'] and resources[('Certificate', 'k3s-buildkit-server')]['spec']['usages'] == ['digital signature', 'server auth'])
check('BuildKit client certificate is separate and client-only', resources[('Certificate', 'k3s-buildkit-client')]['spec']['secretName'] == 'k3s-buildkit-client-tls' and resources[('Certificate', 'k3s-buildkit-client')]['spec']['usages'] == ['digital signature', 'client auth'])
trigger_role = resources[('Role', 'tekton-ci-triggers-role')]['rules']
secret_rules = [rule for rule in trigger_role if rule.get('resources') == ['secrets']]
cluster_refs = resources[('ClusterRole', 'tekton-ci-triggers-clusterrefs')]['rules']
check('Trigger service account can read only the named webhook Secret', len(secret_rules) == 1 and secret_rules[0].get('resourceNames') == ['github-webhook-secret'] and secret_rules[0].get('verbs') == ['get'])
sa_impersonation = [rule for rule in trigger_role if rule.get('resources') == ['serviceaccounts']]
check('Trigger service account can impersonate only the pipeline identity', len(sa_impersonation) == 1 and sa_impersonation[0].get('resourceNames') == ['tekton-ci-pipeline-sa'] and sa_impersonation[0].get('verbs') == ['impersonate'])
role_binding = resources[('RoleBinding', 'tekton-ci-triggers-namespaced-binding')]
check('Trigger namespaced binding uses the scoped chart Role', role_binding['roleRef']['kind'] == 'Role' and role_binding['roleRef']['name'] == 'tekton-ci-triggers-role')
check('Trigger cluster binding excludes the upstream cluster-wide Secret reader', len(cluster_refs) == 1 and cluster_refs[0].get('resources') == ['clustertriggerbindings', 'clusterinterceptors'] and all('secrets' not in rule.get('resources', []) for rule in cluster_refs))
check('Least-privilege trigger binding uses a new immutable roleRef', resources[('ClusterRoleBinding', 'tekton-ci-triggers-clusterrefs-binding')]['roleRef']['name'] == 'tekton-ci-triggers-clusterrefs')
listener = resources[('EventListener', 'github-webhook-listener')]
account = resources[('ServiceAccount', 'pharness-finance-build')]
check('Finance build has no mounted API token', account['automountServiceAccountToken'] is False)
check('Finance build has no chart RBAC binding', not any(subject.get('name') == 'pharness-finance-build' for (kind, _), resource in resources.items() if kind in ['RoleBinding', 'ClusterRoleBinding'] for subject in resource.get('subjects', [])))
check('frontend automatic production webhook absent', not any(t['name'] == 'finance-frontend-trigger' for t in listener['spec']['triggers']))
check('frontend trigger resources absent', not any((kind, 'finance-frontend-' + suffix) in resources for kind, suffix in [('TriggerTemplate', 'template'), ('TriggerBinding', 'binding')]))
print(json.dumps({'checks_passed': len(checks), 'checks': checks, 'scope': 'Rendered contracts and guard execution; no build, credentials or cluster mutations.'}, indent=2))
