#!/usr/bin/env bash
set -euo pipefail

umask 077

readonly DESKTOP_IP="192.168.50.145"
readonly PKI_ROOT="${BUILD_KIT_PKI_ROOT:-$HOME/.config/lucas-engineering/pki/buildkit}"
readonly KEYCHAIN_ACCOUNT="${USER:-buildkit-operator}"
readonly LEAF_DAYS=397
readonly CA_DAYS=1825

usage() {
  printf 'Usage: %s [--rotate-leaves]\n' "$0" >&2
  exit 2
}

rotate=false
case "${1:-}" in
  "") ;;
  --rotate-leaves) rotate=true ;;
  *) usage ;;
esac

for command_name in openssl security; do
  command -v "$command_name" >/dev/null || {
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  }
done

mkdir -p "$PKI_ROOT"
chmod 0700 "$PKI_ROOT"

keychain_service() {
  printf 'lucas-buildkit-%s-ca-passphrase' "$1"
}

ensure_ca() {
  local instance="$1"
  local common_name="$2"
  local directory="$PKI_ROOT/$instance"
  local service
  service="$(keychain_service "$instance")"
  mkdir -p "$directory"
  chmod 0700 "$directory"

  if [ ! -f "$directory/ca-key.pem" ]; then
    local passphrase
    passphrase="$(openssl rand -base64 48)"
    security add-generic-password -U -a "$KEYCHAIN_ACCOUNT" -s "$service" -w "$passphrase" >/dev/null
    BUILDKIT_CA_PASSPHRASE="$passphrase" openssl genpkey \
      -algorithm EC \
      -pkeyopt ec_paramgen_curve:P-256 \
      -aes-256-cbc \
      -pass env:BUILDKIT_CA_PASSPHRASE \
      -out "$directory/ca-key.pem" >/dev/null 2>&1
    BUILDKIT_CA_PASSPHRASE="$passphrase" openssl req \
      -x509 -new -sha256 -days "$CA_DAYS" \
      -key "$directory/ca-key.pem" \
      -passin env:BUILDKIT_CA_PASSPHRASE \
      -subj "/CN=$common_name" \
      -addext 'basicConstraints=critical,CA:TRUE,pathlen:0' \
      -addext 'keyUsage=critical,keyCertSign,cRLSign' \
      -out "$directory/ca.pem" >/dev/null 2>&1
    unset passphrase BUILDKIT_CA_PASSPHRASE
  fi
}

issue_leaf() {
  local instance="$1"
  local role="$2"
  local common_name="$3"
  local extended_key_usage="$4"
  local san="$5"
  local directory="$PKI_ROOT/$instance"
  local service passphrase extfile
  service="$(keychain_service "$instance")"
  passphrase="$(security find-generic-password -a "$KEYCHAIN_ACCOUNT" -s "$service" -w)"
  extfile="$(mktemp)"
  trap 'rm -f "$extfile"' RETURN

  openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 \
    -out "$directory/$role-key.pem" >/dev/null 2>&1
  openssl req -new -sha256 \
    -key "$directory/$role-key.pem" \
    -subj "/CN=$common_name" \
    -out "$directory/$role.csr.pem" >/dev/null 2>&1

  {
    printf '%s\n' 'basicConstraints=critical,CA:FALSE'
    printf '%s\n' 'keyUsage=critical,digitalSignature,keyEncipherment'
    printf 'extendedKeyUsage=%s\n' "$extended_key_usage"
    if [ -n "$san" ]; then
      printf 'subjectAltName=%s\n' "$san"
    fi
  } >"$extfile"

  BUILDKIT_CA_PASSPHRASE="$passphrase" openssl x509 -req \
    -in "$directory/$role.csr.pem" \
    -CA "$directory/ca.pem" \
    -CAkey "$directory/ca-key.pem" \
    -passin env:BUILDKIT_CA_PASSPHRASE \
    -CAcreateserial -days "$LEAF_DAYS" -sha256 \
    -extfile "$extfile" \
    -out "$directory/$role-cert.pem" >/dev/null 2>&1

  rm -f "$directory/$role.csr.pem" "$extfile"
  trap - RETURN
  unset passphrase BUILDKIT_CA_PASSPHRASE
}

verify_leaf() {
  local instance="$1"
  local role="$2"
  openssl verify -CAfile "$PKI_ROOT/$instance/ca.pem" \
    "$PKI_ROOT/$instance/$role-cert.pem" >/dev/null
}

ensure_ca k3s 'Lucas Engineering K3s BuildKit CA'
ensure_ca talos 'Lucas Engineering Talos BuildKit CA'
ensure_ca registry 'Lucas Engineering Internal Registry CA'

if $rotate || [ ! -f "$PKI_ROOT/k3s/server-cert.pem" ]; then
  issue_leaf k3s server 'buildkit-k3s.lucas.internal' serverAuth \
    "DNS:buildkit-k3s.lucas.internal,IP:$DESKTOP_IP"
  issue_leaf k3s client 'k3s-tekton' clientAuth ''
  issue_leaf k3s operator 'k3s-buildkit-operator' clientAuth ''
fi

if $rotate || [ ! -f "$PKI_ROOT/talos/server-cert.pem" ]; then
  issue_leaf talos server 'buildkit-talos.lucas.internal' serverAuth \
    "DNS:buildkit-talos.lucas.internal,IP:$DESKTOP_IP"
  issue_leaf talos client 'talos-tekton' clientAuth ''
  issue_leaf talos operator 'talos-buildkit-operator' clientAuth ''
fi

if $rotate || [ ! -f "$PKI_ROOT/registry/server-cert.pem" ]; then
  issue_leaf registry server 'registry.lucas.engineering' serverAuth \
    'DNS:registry.lucas.engineering,DNS:registry-write-gateway.registry.svc.cluster.local,IP:192.168.20.210'
fi

for instance in k3s talos; do
  for role in server client operator; do
    verify_leaf "$instance" "$role"
  done
  chmod 0600 "$PKI_ROOT/$instance"/*-key.pem
  chmod 0644 "$PKI_ROOT/$instance"/*-cert.pem "$PKI_ROOT/$instance/ca.pem"
  openssl x509 -in "$PKI_ROOT/$instance/ca.pem" -noout -fingerprint -sha256
done

verify_leaf registry server
chmod 0600 "$PKI_ROOT/registry/"*-key.pem
chmod 0644 "$PKI_ROOT/registry/"*-cert.pem "$PKI_ROOT/registry/ca.pem"
openssl x509 -in "$PKI_ROOT/registry/ca.pem" -noout -fingerprint -sha256

printf 'BuildKit PKI is ready under %s\n' "$PKI_ROOT"
