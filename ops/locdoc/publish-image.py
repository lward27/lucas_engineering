#!/usr/bin/env python3
"""Publish a docker-save OCI archive through the authenticated internal gateway."""
import base64, http.client, json, ssl, tarfile, urllib.parse

host = 'registry-write-gateway.registry.svc.cluster.local:8443'
repo = 'locdoc-oms'
tag = 'cluster-20261106-r9'
auths = json.load(open('/auth/.dockerconfigjson'))['auths']
authorization = 'Basic ' + auths[host]['auth']
context = ssl.create_default_context(cafile='/certs/ca.crt')
archive = tarfile.open('/work/oms-r9.tar')

def blob(digest):
    return archive.extractfile('blobs/sha256/' + digest.split(':', 1)[1])

def request(method, path, body=None, headers=None):
    conn = http.client.HTTPSConnection(host, context=context, timeout=300)
    h = {'Authorization': authorization, **(headers or {})}
    conn.request(method, path, body=body, headers=h)
    response = conn.getresponse()
    data = response.read()
    if response.status >= 400:
        raise RuntimeError(f'{method} {path.split("?")[0]}: HTTP {response.status}')
    return response, data

index = json.load(archive.extractfile('index.json'))
outer = json.load(blob(index['manifests'][0]['digest']))
entry = next(m for m in outer['manifests'] if m.get('platform', {}).get('os') == 'linux' and m.get('platform', {}).get('architecture') == 'amd64')
manifest_bytes = blob(entry['digest']).read()
manifest = json.loads(manifest_bytes)
for desc in [manifest['config'], *manifest['layers']]:
    digest = desc['digest']
    try:
        request('HEAD', f'/v2/{repo}/blobs/{digest}')
        continue
    except RuntimeError as exc:
        if 'HTTP 404' not in str(exc):
            raise
    response, _ = request('POST', f'/v2/{repo}/blobs/uploads/', body=b'', headers={'Content-Length': '0'})
    location = urllib.parse.urlsplit(response.getheader('Location'))
    path = location.path + ('?' + location.query + '&' if location.query else '?') + urllib.parse.urlencode({'digest': digest})
    request('PUT', path, body=blob(digest), headers={'Content-Type': 'application/octet-stream', 'Content-Length': str(desc['size'])})
    print('uploaded', digest, flush=True)
request('PUT', f'/v2/{repo}/manifests/{tag}', body=manifest_bytes, headers={'Content-Type': entry['mediaType'], 'Content-Length': str(len(manifest_bytes))})
print('published', entry['digest'], flush=True)
