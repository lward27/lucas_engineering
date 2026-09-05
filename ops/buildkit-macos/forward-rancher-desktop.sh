#!/usr/bin/env bash
# Keep BuildKit mTLS end-to-end through Rancher Desktop's existing local VM SSH.
set -euo pipefail
bind_address="${1:?Usage: forward-rancher-desktop.sh <Mac VPN IPv4 address>}"
case "$bind_address" in ''|*[!0-9.]*) echo 'Expected an IPv4 bind address' >&2; exit 2 ;; esac
ssh_configuration="$HOME/Library/Application Support/rancher-desktop/lima/0/ssh.config"
test -r "$ssh_configuration"
exec ssh -F "$ssh_configuration" \
  -o ControlMaster=no -o ControlPath=none -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=15 -o ServerAliveCountMax=3 \
  -N -L "$bind_address:12340:127.0.0.1:12344" lima-0
