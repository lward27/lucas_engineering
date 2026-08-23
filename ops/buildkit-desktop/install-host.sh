#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  printf 'Run this installer with sudo.\n' >&2
  exit 1
fi

readonly PKI_SOURCE="${1:-/var/tmp/pki}"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SOURCE_DIR
readonly BUILDKIT_VERSION="v0.32.2"
readonly BUILDKIT_ARCHIVE="buildkit-v0.32.2.linux-amd64.tar.gz"
readonly BUILDKIT_SHA256="2975d0f651ad96ba8b80b9992ae1f9a964f4408569af5b6dc36544165c3926af"
readonly BUILDKIT_URL="https://github.com/moby/buildkit/releases/download/$BUILDKIT_VERSION/$BUILDKIT_ARCHIVE"

test "$(uname -m)" = x86_64 || { printf 'This installer supports x86_64 only.\n' >&2; exit 1; }
ip -4 addr show wlp39s0 | grep -q '192\.168\.50\.145/24' || {
  printf 'Expected 192.168.50.145/24 on wlp39s0; refusing to bind the configured endpoints.\n' >&2
  exit 1
}
mountpoint -q /storage/minio-fast || { printf '/storage/minio-fast is not mounted.\n' >&2; exit 1; }

for file in \
  "$PKI_SOURCE/k3s/ca.pem" "$PKI_SOURCE/k3s/server-cert.pem" "$PKI_SOURCE/k3s/server-key.pem" \
  "$PKI_SOURCE/k3s/operator-cert.pem" "$PKI_SOURCE/k3s/operator-key.pem" \
  "$PKI_SOURCE/talos/ca.pem" "$PKI_SOURCE/talos/server-cert.pem" "$PKI_SOURCE/talos/server-key.pem" \
  "$PKI_SOURCE/talos/operator-cert.pem" "$PKI_SOURCE/talos/operator-key.pem" \
  "$PKI_SOURCE/registry/ca.pem"
do
  test -r "$file" || { printf 'Missing staged file: %s\n' "$file" >&2; exit 1; }
done

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates curl fuse-overlayfs nftables rootlesskit slirp4netns uidmap

for instance in k3s talos; do
  user="buildkit-$instance"
  if ! getent passwd "$user" >/dev/null; then
    useradd --system --create-home --home-dir "/var/lib/$user" --shell /usr/sbin/nologin "$user"
  fi
done

ensure_subids() {
  local user="$1" start="$2" file range
  local end=$((start + 65535))
  range="$start-$end"
  for file in /etc/subuid /etc/subgid; do
    if ! grep -qE "^${user}:${start}:65536$" "$file"; then
      if awk -F: -v user="$user" -v start="$start" -v end="$end" '
        $1 != user { other_start=$2; other_end=$2+$3-1; if (start <= other_end && end >= other_start) exit 1 }
      ' "$file"; then
        if [ "$file" = /etc/subuid ]; then
          usermod --add-subuids "$range" "$user"
        else
          usermod --add-subgids "$range" "$user"
        fi
      else
        printf 'Requested subordinate-ID range %s overlaps another user in %s.\n' "$range" "$file" >&2
        exit 1
      fi
    fi
  done
}

ensure_subids buildkit-k3s 200000
ensure_subids buildkit-talos 300000

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
curl --fail --location --silent --show-error "$BUILDKIT_URL" -o "$tmpdir/$BUILDKIT_ARCHIVE"
printf '%s  %s\n' "$BUILDKIT_SHA256" "$tmpdir/$BUILDKIT_ARCHIVE" | sha256sum --check --status
mkdir -p "/usr/local/lib/buildkit/$BUILDKIT_VERSION"
tar -xzf "$tmpdir/$BUILDKIT_ARCHIVE" -C "/usr/local/lib/buildkit/$BUILDKIT_VERSION"
test -x "/usr/local/lib/buildkit/$BUILDKIT_VERSION/bin/buildkitd"
test -x "/usr/local/lib/buildkit/$BUILDKIT_VERSION/bin/buildctl"
test -x "/usr/local/lib/buildkit/$BUILDKIT_VERSION/bin/buildkit-runc"
ln -sfn "/usr/local/lib/buildkit/$BUILDKIT_VERSION" /usr/local/lib/buildkit/current

install -d -m 0755 /etc/buildkit /usr/local/libexec /usr/local/sbin
for instance in k3s talos; do
  user="buildkit-$instance"
  install -d -o "$user" -g "$user" -m 0700 "/storage/minio-fast/buildkit/$instance"
  install -d -o root -g "$user" -m 0750 "/etc/buildkit/$instance" "/etc/buildkit/$instance/pki"
  install -o root -g "$user" -m 0440 "$PKI_SOURCE/$instance/ca.pem" "/etc/buildkit/$instance/pki/ca.pem"
  install -o root -g "$user" -m 0440 "$PKI_SOURCE/$instance/server-cert.pem" "/etc/buildkit/$instance/pki/server-cert.pem"
  install -o root -g "$user" -m 0440 "$PKI_SOURCE/$instance/server-key.pem" "/etc/buildkit/$instance/pki/server-key.pem"
  install -o root -g "$user" -m 0440 "$PKI_SOURCE/$instance/operator-cert.pem" "/etc/buildkit/$instance/pki/operator-cert.pem"
  install -o root -g "$user" -m 0440 "$PKI_SOURCE/$instance/operator-key.pem" "/etc/buildkit/$instance/pki/operator-key.pem"
done
install -o root -g buildkit-k3s -m 0440 "$PKI_SOURCE/registry/ca.pem" /etc/buildkit/k3s/registry-internal-ca.pem

install -o root -g buildkit-k3s -m 0440 "$SOURCE_DIR/buildkitd-k3s.toml" /etc/buildkit/k3s/buildkitd.toml
install -o root -g buildkit-talos -m 0440 "$SOURCE_DIR/buildkitd-talos.toml" /etc/buildkit/talos/buildkitd.toml
install -m 0755 "$SOURCE_DIR/bin/run-buildkit-k3s" /usr/local/libexec/run-buildkit-k3s
install -m 0755 "$SOURCE_DIR/bin/run-buildkit-talos" /usr/local/libexec/run-buildkit-talos
install -m 0755 "$SOURCE_DIR/bin/buildkitctl-k3s" /usr/local/sbin/buildkitctl-k3s
install -m 0755 "$SOURCE_DIR/bin/buildkitctl-talos" /usr/local/sbin/buildkitctl-talos

k3s_uid="$(id -u buildkit-k3s)"
talos_uid="$(id -u buildkit-talos)"
sed -e "s/@K3S_UID@/$k3s_uid/g" -e "s/@TALOS_UID@/$talos_uid/g" \
  "$SOURCE_DIR/nftables/buildkit-firewall.nft.in" >/etc/buildkit/buildkit-firewall.nft
chmod 0600 /etc/buildkit/buildkit-firewall.nft

install -m 0644 "$SOURCE_DIR/systemd/buildkit.slice" /etc/systemd/system/buildkit.slice
install -m 0644 "$SOURCE_DIR/systemd/buildkit-firewall.service" /etc/systemd/system/buildkit-firewall.service
install -m 0644 "$SOURCE_DIR/systemd/buildkit-k3s.service" /etc/systemd/system/buildkit-k3s.service
install -m 0644 "$SOURCE_DIR/systemd/buildkit-talos.service" /etc/systemd/system/buildkit-talos.service

nft --check -f /etc/buildkit/buildkit-firewall.nft
systemd-analyze verify \
  /etc/systemd/system/buildkit.slice \
  /etc/systemd/system/buildkit-firewall.service \
  /etc/systemd/system/buildkit-k3s.service \
  /etc/systemd/system/buildkit-talos.service

if command -v ufw >/dev/null && ufw status | grep -q '^Status: active'; then
  ufw allow from 192.168.20.192 to 192.168.50.145 port 12340 proto tcp
  ufw allow from 192.168.20.210 to 192.168.50.145 port 12340 proto tcp
  ufw allow from 192.168.20.223 to 192.168.50.145 port 12341 proto tcp
  ufw allow from 192.168.20.224 to 192.168.50.145 port 12341 proto tcp
  ufw allow from 192.168.20.225 to 192.168.50.145 port 12341 proto tcp
fi

systemctl daemon-reload
systemctl enable --now buildkit-firewall.service buildkit-k3s.service buildkit-talos.service
systemctl --no-pager --full status buildkit-firewall.service buildkit-k3s.service buildkit-talos.service
