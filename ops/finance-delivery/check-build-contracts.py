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
        result = shell(script, {'IMAGE': 'registry.test/finance:git-' + 'a' * 40, 'RESULT_IMAGE_URL': ''})
        check('BuildKit result ' + label, (result == 0) == valid)
        if valid:
            check('BuildKit exact result preserved', (root / 'digest').read_text() == digest and (root / 'image').read_text() == 'registry.test/finance:git-' + 'a' * 40)
listener = resources[('EventListener', 'github-webhook-listener')]
check('frontend automatic production webhook absent', not any(t['name'] == 'finance-frontend-trigger' for t in listener['spec']['triggers']))
check('frontend trigger resources absent', not any((kind, 'finance-frontend-' + suffix) in resources for kind, suffix in [('TriggerTemplate', 'template'), ('TriggerBinding', 'binding')]))
print(json.dumps({'checks_passed': len(checks), 'checks': checks, 'scope': 'Rendered contracts and guard execution; no build, credentials or cluster mutations.'}, indent=2))
