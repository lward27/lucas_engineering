#!/usr/bin/env bash
set -euo pipefail

INCIDENT_ID=""
CONTEXT=""
OUTPUT_ROOT=""
CREATE=false

usage() {
  cat <<'EOF'
Usage: artifact-path.sh --incident-id ID [--context CONTEXT] [--output-root DIR] [--create]

Print a safe incident-artifact path. With --create, create only that path.
EOF
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    --incident-id) INCIDENT_ID=${2:-}; shift 2 ;;
    --context) CONTEXT=${2:-}; shift 2 ;;
    --output-root) OUTPUT_ROOT=${2:-}; shift 2 ;;
    --create) CREATE=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n "$INCIDENT_ID" ]] || fail "--incident-id is required"
[[ "$INCIDENT_ID" =~ ^[A-Za-z0-9._-]+$ ]] || fail "incident id may contain only letters, digits, dot, underscore, and hyphen"

if [[ -z "$OUTPUT_ROOT" ]]; then
  if repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
    OUTPUT_ROOT="$repo_root/.artifacts/k8s-ops"
  else
    OUTPUT_ROOT="$HOME/.local/share/k8s-ops"
  fi
fi

timestamp=$(date -u +%Y%m%dT%H%M%SZ)
artifact_dir="$OUTPUT_ROOT/$INCIDENT_ID/$timestamp"

if [[ "$CREATE" == true ]]; then
  mkdir -p "$artifact_dir"
fi

printf '%s\n' "$artifact_dir"
