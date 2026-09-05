#!/usr/bin/env bash
# Temporary Lucas Engineering build host while ubuntu-desktop is powered off.
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
pki_directory="$HOME/.config/lucas-engineering/pki/buildkit/k3s"
configuration_directory="$HOME/.config/lucas-engineering/buildkit-macos"
image='docker.io/moby/buildkit@sha256:59795d5a98a9e12ddf49567fcd1976a30f2d2a60ef469c2f9cedb9e5e3251b25'

for file in ca.pem server-cert.pem server-key.pem; do
  test -r "$pki_directory/$file" || { echo "Missing existing K3s PKI file: $file" >&2; exit 1; }
done
if docker --context rancher-desktop container inspect astra-tekton-buildkit >/dev/null 2>&1; then
  echo 'astra-tekton-buildkit already exists; inspect its current state before changing it.' >&2
  exit 1
fi
mkdir -p "$configuration_directory"
install -m 0644 "$script_directory/buildkitd.toml" "$configuration_directory/buildkitd.toml"
# The standard rootful BuildKit container runs inside Rancher Desktop's VM.
# Its API is mutually authenticated and published on the VM's loopback only.
# forward-rancher-desktop.sh uses the existing Lima SSH connection to expose
# that port on the Mac VPN interface without terminating BuildKit TLS.
# Neither the Mac filesystem nor the Docker socket is exposed to build steps.
docker --context rancher-desktop run --detach \
  --name astra-tekton-buildkit --restart unless-stopped \
  --platform linux/arm64 --privileged --cpus 2 --memory 2g \
  --publish "127.0.0.1:12344:12340" \
  --mount type=volume,src=astra-tekton-buildkit-state,dst=/var/lib/buildkit \
  --mount "type=bind,src=$configuration_directory/buildkitd.toml,dst=/etc/buildkit/buildkitd.toml,readonly" \
  --mount "type=bind,src=$pki_directory/ca.pem,dst=/etc/buildkit/pki/ca.pem,readonly" \
  --mount "type=bind,src=$pki_directory/server-cert.pem,dst=/etc/buildkit/pki/server-cert.pem,readonly" \
  --mount "type=bind,src=$pki_directory/server-key.pem,dst=/etc/buildkit/pki/server-key.pem,readonly" \
  "$image" --config /etc/buildkit/buildkitd.toml
