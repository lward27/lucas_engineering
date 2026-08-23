# Dual rootless BuildKit services

This directory is the non-secret source of truth for the two BuildKit daemons
on `ubuntu-desktop` (`192.168.50.145`). The desktop remains an Ubuntu desktop;
it is not a Kubernetes node and does not run Docker.

| Instance | Host port | TLS server name | State limit |
|---|---:|---|---:|
| K3s | 12340 | `buildkit-k3s.lucas.internal` | 200 GB |
| Talos | 12341 | `buildkit-talos.lucas.internal` | 140 GB |

Both daemons are rootless and run under different Linux users, subordinate-ID
ranges, network namespaces, TLS authorities, and state directories. The shared
`buildkit.slice` bounds their aggregate CPU and memory use.

## Prerequisites

1. Reserve `192.168.50.145` for the desktop in UniFi.
2. Add these stateful inter-VLAN rules above the default deny:
   - `192.168.20.192,192.168.20.210` to `192.168.50.145:12340/TCP`
   - `192.168.20.223-192.168.20.225` to `192.168.50.145:12341/TCP`
   - `192.168.50.145` to `192.168.20.210:32443/TCP`
3. Generate the BuildKit and internal-registry PKI on the management Mac:

   ```sh
   ./ops/buildkit-desktop/generate-pki.sh
   ```

The generated private material lives under
`~/.config/lucas-engineering/pki/buildkit`, is ignored by this repository, and
must be covered by an encrypted workstation backup.

The public `registry.lucas.engineering` route continues through Cloudflare and
ingress-nginx; Caddy is not part of this path. A dedicated in-cluster NGINX
gateway accepts anonymous `GET`/`HEAD`, requires Basic authentication for
write methods, and runs one replica per K3s node. The desktop targets its
private-CA TLS NodePort at `192.168.20.210:32443`. The K3s RootlessKit namespace maps
`registry.lucas.engineering:443` to that private NodePort so image names remain
unchanged and large uploads do not traverse Cloudflare.

## Install over SSH

Stage only the BuildKit server/operator certificates and the registry public
CA certificate:

```sh
staging="$(mktemp -d)"
cp -R ops/buildkit-desktop "$staging/source"
mkdir -p "$staging/pki/k3s" "$staging/pki/talos"
cp ~/.config/lucas-engineering/pki/buildkit/k3s/{ca.pem,server-cert.pem,server-key.pem,operator-cert.pem,operator-key.pem} "$staging/pki/k3s/"
cp ~/.config/lucas-engineering/pki/buildkit/talos/{ca.pem,server-cert.pem,server-key.pem,operator-cert.pem,operator-key.pem} "$staging/pki/talos/"
mkdir -p "$staging/pki/registry"
cp ~/.config/lucas-engineering/pki/buildkit/registry/ca.pem "$staging/pki/registry/"
scp -r "$staging/source" "$staging/pki" lucas-desktop:/var/tmp/
ssh -t lucas-desktop 'sudo /var/tmp/source/install-host.sh /var/tmp/pki'
```

The CA private keys, registry server key, and Kubernetes client private keys
must never be copied to the desktop.

Before merging the registry gateway, create its TLS/auth Secrets and refresh
the two BuildKit client Secrets without printing their values:

```sh
./ops/buildkit-desktop/provision-cluster-secrets.sh
```

## Verification

```sh
ssh lucas-desktop 'systemctl is-active buildkit-k3s buildkit-talos buildkit-firewall'
ssh lucas-desktop 'ss -ltn | grep -E "192.168.50.145:(12340|12341)|127.0.0.1:1606[01]"'
ssh lucas-desktop 'sudo -u buildkit-k3s /usr/local/sbin/buildkitctl-k3s debug workers'
ssh lucas-desktop 'sudo -u buildkit-talos /usr/local/sbin/buildkitctl-talos debug workers'
ssh lucas-desktop 'df -h /storage/minio-fast && systemctl status buildkit.slice'
```

Logs and cache usage:

```sh
ssh lucas-desktop 'journalctl -u buildkit-k3s -u buildkit-talos --since today'
ssh lucas-desktop 'sudo -u buildkit-k3s /usr/local/sbin/buildkitctl-k3s du'
ssh lucas-desktop 'sudo -u buildkit-talos /usr/local/sbin/buildkitctl-talos du'
```

Stop both services before a gaming session only if a build is not active:

```sh
ssh lucas-desktop 'sudo systemctl stop buildkit-k3s buildkit-talos'
# Later:
ssh lucas-desktop 'sudo systemctl start buildkit-k3s buildkit-talos'
```

## Certificate rotation

Leaf certificates expire after 397 days. Rotate them at least 30 days early:

1. Re-run `generate-pki.sh --rotate-leaves`.
2. Replace one Kubernetes client Secret and verify a smoke build.
3. Replace that instance's server/operator files and restart only its service.
4. Repeat for the other instance.

A compromised client requires rotation of that instance's CA and all of its
certificates because BuildKit does not consume a certificate revocation list.
Rotate the independent registry leaf/CA on the same schedule and refresh
`registry-internal-tls` plus the desktop's public trust copy.
