#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROFILE="$SCRIPT_DIR/../references/cluster-profile.yaml"
CONTEXT=""
INTENT="observation"

usage() {
  cat <<'EOF'
Usage: context-guard.sh --context CONTEXT [--intent observation|write] [--profile FILE]

Resolve a profile alias to its actual kubeconfig context. Never switches context.
EOF
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    --context) CONTEXT=${2:-}; shift 2 ;;
    --intent) INTENT=${2:-}; shift 2 ;;
    --profile) PROFILE=${2:-}; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n "$CONTEXT" ]] || fail "--context is required"
[[ "$INTENT" == "observation" || "$INTENT" == "write" ]] || fail "--intent must be observation or write"
[[ -r "$PROFILE" ]] || fail "profile is not readable: $PROFILE"

entry=$(awk -v requested="$CONTEXT" '
  function clean(value) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
    gsub(/"/, "", value)
    return value
  }
  function alias_match() {
    return name == requested || index("," aliases ",", "," requested ",") > 0
  }
  function emit() {
    if (name != "" && alias_match()) {
      print name "\t" kubeconfig "\t" environment "\t" writes "\t" server
    }
    name = ""; aliases = ""; kubeconfig = ""; environment = ""; writes = ""; server = ""
  }
  /^approved_contexts:/ { in_profiles = 1; next }
  in_profiles && /^unknown_context_policy:/ { emit(); in_profiles = 0; next }
  in_profiles && /^  - name:/ {
    emit()
    name = $0
    sub(/^  - name:[[:space:]]*/, "", name)
    name = clean(name)
    next
  }
  in_profiles && name != "" && /^    aliases:/ {
    aliases = $0
    sub(/^    aliases:[[:space:]]*/, "", aliases)
    gsub(/\[/, "", aliases); gsub(/\]/, "", aliases); gsub(/"/, "", aliases); gsub(/[[:space:]]/, "", aliases)
    next
  }
  in_profiles && name != "" && /^    kubeconfig:/ {
    kubeconfig = $0
    sub(/^    kubeconfig:[[:space:]]*/, "", kubeconfig)
    kubeconfig = clean(kubeconfig)
    next
  }
  in_profiles && name != "" && /^    environment:/ {
    environment = $0
    sub(/^    environment:[[:space:]]*/, "", environment)
    environment = clean(environment)
    next
  }
  in_profiles && name != "" && /^    writes_allowed:/ {
    writes = $0
    sub(/^    writes_allowed:[[:space:]]*/, "", writes)
    writes = clean(writes)
    next
  }
  in_profiles && name != "" && /^    api_server:/ {
    server = $0
    sub(/^    api_server:[[:space:]]*/, "", server)
    server = clean(server)
    next
  }
  END { if (in_profiles) emit() }
' "$PROFILE")

[[ "$(printf '%s\n' "$entry" | awk 'NF { count++ } END { print count+0 }')" -le 1 ]] || fail "profile alias is ambiguous"

if [[ -z "$entry" ]]; then
  printf 'requested_context=%s\n' "$CONTEXT"
  printf 'resolved_context=\n'
  printf 'approved=false\n'
  printf 'writes_allowed=false\n'
  printf 'environment=unknown\n'
  if [[ "$INTENT" == "write" ]]; then
    printf 'error: requested write targets an unapproved context\n' >&2
    exit 4
  fi
  exit 0
fi

IFS=$'\t' read -r RESOLVED KUBECONFIG ENVIRONMENT WRITES_ALLOWED EXPECTED_SERVER <<< "$entry"
if [[ "$KUBECONFIG" == \~/* ]]; then
  KUBECONFIG="$HOME/${KUBECONFIG:2}"
fi
[[ -r "$KUBECONFIG" ]] || fail "profile kubeconfig is not readable: $KUBECONFIG"
command -v kubectl >/dev/null 2>&1 || fail "kubectl is required to validate a known context"

if ! kubectl --kubeconfig "$KUBECONFIG" --request-timeout=20s config get-contexts -o name | awk -v wanted="$RESOLVED" '$0 == wanted { found = 1 } END { exit found ? 0 : 1 }'; then
  fail "resolved context is absent from its configured kubeconfig"
fi

if [[ -n "$EXPECTED_SERVER" ]]; then
  actual_server=$(kubectl --kubeconfig "$KUBECONFIG" --context "$RESOLVED" --request-timeout=20s config view --minify -o 'jsonpath={.clusters[0].cluster.server}')
  [[ "$actual_server" == "$EXPECTED_SERVER" ]] || fail "kubeconfig server differs from approved profile"
fi

if [[ "$INTENT" == "write" && "$WRITES_ALLOWED" != "true" ]]; then
  printf 'error: profile forbids writes to this context\n' >&2
  exit 4
fi

printf 'requested_context=%s\n' "$CONTEXT"
printf 'resolved_context=%s\n' "$RESOLVED"
printf 'kubeconfig=%s\n' "$KUBECONFIG"
printf 'approved=true\n'
printf 'writes_allowed=%s\n' "$WRITES_ALLOWED"
printf 'environment=%s\n' "$ENVIRONMENT"
