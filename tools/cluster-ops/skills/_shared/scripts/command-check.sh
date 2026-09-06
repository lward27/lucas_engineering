#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONTEXT=""
NAMESPACE=""
COMMAND_TEXT=""

usage() {
  cat <<'EOF'
Usage: command-check.sh --context CONTEXT --command TEXT [--namespace NAMESPACE]

Classify a proposed operation and resolve its context without executing it.
EOF
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    --context) CONTEXT=${2:-}; shift 2 ;;
    --namespace) NAMESPACE=${2:-}; shift 2 ;;
    --command) COMMAND_TEXT=${2:-}; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n "$CONTEXT" ]] || fail "--context is required"
[[ -n "$COMMAND_TEXT" ]] || fail "--command is required"

set +e
classification=$("$SCRIPT_DIR/operation-classifier.sh" --context "$CONTEXT" --command "$COMMAND_TEXT")
classification_status=$?
set -e
printf '%s\n' "$classification"

if ((classification_status != 0)); then
  printf 'next_step=clarify-the-operation-before-running-it\n'
  exit "$classification_status"
fi

operation_class=$(awk -F= '$1 == "class" { print $2 }' <<< "$classification")
intent="observation"
if [[ "$operation_class" != "observation" ]]; then
  intent="write"
fi

"$SCRIPT_DIR/context-guard.sh" --context "$CONTEXT" --intent "$intent"
if [[ -n "$NAMESPACE" ]]; then
  printf 'namespace=%s\n' "$NAMESPACE"
fi
if [[ "$operation_class" == "destructive-high-risk" ]]; then
  printf 'class_c_gate=final-explicit-confirmation-required-before-execution\n'
fi
