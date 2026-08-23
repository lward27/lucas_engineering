#!/usr/bin/env bash
set -euo pipefail

umask 077

readonly PKI_ROOT="${BUILD_KIT_PKI_ROOT:-$HOME/.config/lucas-engineering/pki/buildkit}"
readonly K3S_KUBECONFIG="${K3S_KUBECONFIG:-$HOME/.kube/config}"
readonly K3S_CONTEXT="${K3S_CONTEXT:-lucas_engineering}"
readonly TALOS_KUBECONFIG="${TALOS_KUBECONFIG:-$HOME/.kube/lucas-engineering-agent-config}"
readonly TALOS_CONTEXT="${TALOS_CONTEXT:-admin@lucas-engineering-agent-homelab}"
readonly REGISTRY_USER="buildkit-k3s"
readonly REGISTRY_HOST="registry.lucas.engineering"
readonly REGISTRY_INTERNAL_HOST="registry-write-gateway.registry.svc.cluster.local:8443"
readonly KEYCHAIN_SERVICE="lucas-registry-buildkit-push"
readonly KEYCHAIN_ACCOUNT="${USER:-buildkit-operator}"
readonly SECRET_ROOT="${BUILD_KIT_SECRET_ROOT:-$HOME/.config/lucas-engineering/secrets/buildkit}"

for file in \
  "$PKI_ROOT/k3s/ca.pem" "$PKI_ROOT/k3s/client-cert.pem" "$PKI_ROOT/k3s/client-key.pem" \
  "$PKI_ROOT/talos/ca.pem" "$PKI_ROOT/talos/client-cert.pem" "$PKI_ROOT/talos/client-key.pem" \
  "$PKI_ROOT/registry/server-cert.pem" "$PKI_ROOT/registry/server-key.pem"
do
  test -r "$file" || { printf 'Missing required PKI file: %s\n' "$file" >&2; exit 1; }
done

mkdir -p "$SECRET_ROOT"
chmod 0700 "$SECRET_ROOT"

if ! security find-generic-password -a "$KEYCHAIN_ACCOUNT" -s "$KEYCHAIN_SERVICE" -w >/dev/null 2>&1; then
  registry_password="$(openssl rand -base64 48)"
  security add-generic-password -U -a "$KEYCHAIN_ACCOUNT" -s "$KEYCHAIN_SERVICE" -w "$registry_password" >/dev/null
  unset registry_password
fi

registry_password="$(security find-generic-password -a "$KEYCHAIN_ACCOUNT" -s "$KEYCHAIN_SERVICE" -w)"
registry_auth="$(printf '%s:%s' "$REGISTRY_USER" "$registry_password" | openssl base64 -A)"
jq -n --arg host "$REGISTRY_HOST" --arg internalHost "$REGISTRY_INTERNAL_HOST" --arg auth "$registry_auth" \
  '{auths:{($host):{auth:$auth},($internalHost):{auth:$auth}}}' >"$SECRET_ROOT/k3s-registry-config.json"
/usr/sbin/htpasswd -bnBC 14 "$REGISTRY_USER" "$registry_password" \
  >"$SECRET_ROOT/registry-htpasswd"
chmod 0600 "$SECRET_ROOT"/*
unset registry_password registry_auth

kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" \
  -n tekton-pipelines create secret generic remote-buildkit-client-tls \
  --from-file=ca.pem="$PKI_ROOT/k3s/ca.pem" \
  --from-file=cert.pem="$PKI_ROOT/k3s/client-cert.pem" \
  --from-file=key.pem="$PKI_ROOT/k3s/client-key.pem" \
  --dry-run=client -o yaml \
  | kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" apply -f -

kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" \
  -n tekton-pipelines create secret generic lucas-registry-push \
  --type=kubernetes.io/dockerconfigjson \
  --from-file=.dockerconfigjson="$SECRET_ROOT/k3s-registry-config.json" \
  --dry-run=client -o yaml \
  | kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" apply -f -

kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" \
  -n tekton-pipelines create secret generic registry-internal-ca \
  --from-file=ca.crt="$PKI_ROOT/registry/ca.pem" \
  --dry-run=client -o yaml \
  | kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" apply -f -

kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" \
  -n registry create secret generic registry-write-auth \
  --from-file=auth="$SECRET_ROOT/registry-htpasswd" \
  --dry-run=client -o yaml \
  | kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" apply -f -

kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" \
  -n registry create secret tls registry-internal-tls \
  --cert="$PKI_ROOT/registry/server-cert.pem" \
  --key="$PKI_ROOT/registry/server-key.pem" \
  --dry-run=client -o yaml \
  | kubectl --kubeconfig "$K3S_KUBECONFIG" --context "$K3S_CONTEXT" apply -f -

kubectl --kubeconfig "$TALOS_KUBECONFIG" --context "$TALOS_CONTEXT" \
  -n lea-ci create secret generic lea-buildkit-client-tls \
  --from-file=ca.pem="$PKI_ROOT/talos/ca.pem" \
  --from-file=cert.pem="$PKI_ROOT/talos/client-cert.pem" \
  --from-file=key.pem="$PKI_ROOT/talos/client-key.pem" \
  --dry-run=client -o yaml \
  | kubectl --kubeconfig "$TALOS_KUBECONFIG" --context "$TALOS_CONTEXT" apply -f -

printf 'Cluster prerequisite Secret objects are present; values were not printed.\n'
