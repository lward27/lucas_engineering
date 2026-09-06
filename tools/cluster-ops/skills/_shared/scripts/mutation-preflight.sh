#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONTEXT=""
NAMESPACE=""
RESOURCE=""
OPERATION=""
ARGV_JSON=""
PROFILE=""
MANIFEST=""
ACK_CLASS_C=false

usage() {
  cat <<'EOF'
Usage: mutation-preflight.sh --context CONTEXT --namespace NAMESPACE --resource TYPE/NAME (--argv-json JSON | --operation TEXT) [--profile FILE] [--manifest FILE] [--acknowledge-class-c]

Validate mutation context and scope. This script never executes the proposed mutation.
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
    --resource) RESOURCE=${2:-}; shift 2 ;;
    --operation) OPERATION=${2:-}; shift 2 ;;
    --argv-json) ARGV_JSON=${2:-}; shift 2 ;;
    --profile) PROFILE=${2:-}; shift 2 ;;
    --manifest) MANIFEST=${2:-}; shift 2 ;;
    --acknowledge-class-c) ACK_CLASS_C=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n "$CONTEXT" ]] || fail "--context is required"
[[ -n "$NAMESPACE" ]] || fail "--namespace is required"
[[ -n "$RESOURCE" ]] || fail "--resource is required"
[[ -n "$OPERATION" || -n "$ARGV_JSON" ]] || fail "--argv-json or --operation is required"
[[ -z "$OPERATION" || -z "$ARGV_JSON" ]] || fail "provide only one operation input"
[[ "$RESOURCE" != *"*"* ]] || fail "wildcard resources are not allowed"
[[ "$RESOURCE" != *","* ]] || fail "preflight accepts one resource at a time"
if [[ -n "$MANIFEST" ]]; then
  [[ -r "$MANIFEST" ]] || fail "manifest is not readable: $MANIFEST"
fi

operation_args=(--context "$CONTEXT")
if [[ -n "$ARGV_JSON" ]]; then
  operation_args+=(--argv-json "$ARGV_JSON")
else
  operation_args+=(--command "$OPERATION")
fi
classification=$("$SCRIPT_DIR/operation-classifier.sh" "${operation_args[@]}")
operation_class=$(awk -F= '$1 == "class" { print $2 }' <<< "$classification")
[[ "$operation_class" != "observation" ]] || fail "preflight is for mutations, not observation"

guard_args=(--context "$CONTEXT" --intent write)
if [[ -n "$PROFILE" ]]; then guard_args+=(--profile "$PROFILE"); fi
guard=$("$SCRIPT_DIR/context-guard.sh" "${guard_args[@]}")
resolved_context=$(awk -F= '$1 == "resolved_context" { print $2 }' <<< "$guard")
kubeconfig=$(awk -F= '$1 == "kubeconfig" { print $2 }' <<< "$guard")
[[ -n "$resolved_context" && -n "$kubeconfig" ]] || fail "approved context resolution failed"

if [[ "$operation_class" == "destructive-high-risk" && "$ACK_CLASS_C" != true ]]; then
  printf 'class=%s\n' "$operation_class"
  printf 'result=blocked-awaiting-final-explicit-confirmation\n'
  exit 4
fi

owner=$(kubectl --kubeconfig "$kubeconfig" --context "$resolved_context" --request-timeout=20s --namespace "$NAMESPACE" get "$RESOURCE" --ignore-not-found -o jsonpath='{.metadata.labels.argocd\.argoproj\.io/instance}' 2>/dev/null) || fail "GitOps ownership check failed; ownership is unknown"
if [[ -z "$owner" ]]; then
  owner="not-detected-or-resource-not-found"
fi

printf '%s\n' "$guard"
printf 'namespace=%s\n' "$NAMESPACE"
printf 'resource=%s\n' "$RESOURCE"
printf 'class=%s\n' "$operation_class"
printf 'argocd_owner=%s\n' "$owner"
printf 'execution=not-run\n'

if [[ -n "$MANIFEST" ]]; then
  printf 'client_dry_run=starting\n'
  set +e
  kubectl --kubeconfig "$kubeconfig" --context "$resolved_context" --request-timeout=20s --namespace "$NAMESPACE" apply --dry-run=client -f "$MANIFEST" 2>&1 | "$SCRIPT_DIR/redact-output.sh"
  pipeline_status=("${PIPESTATUS[@]}")
  client_status=${pipeline_status[0]}
  set -e
  printf 'client_dry_run_exit=%s\n' "$client_status"
  [[ "$client_status" == 0 ]] || exit "$client_status"
  [[ "${pipeline_status[1]}" == 0 ]] || fail "redaction failed"

  printf 'server_dry_run=starting\n'
  set +e
  kubectl --kubeconfig "$kubeconfig" --context "$resolved_context" --request-timeout=20s --namespace "$NAMESPACE" apply --dry-run=server -f "$MANIFEST" 2>&1 | "$SCRIPT_DIR/redact-output.sh"
  pipeline_status=("${PIPESTATUS[@]}")
  server_status=${pipeline_status[0]}
  set -e
  printf 'server_dry_run_exit=%s\n' "$server_status"
  [[ "$server_status" == 0 ]] || exit "$server_status"
  [[ "${pipeline_status[1]}" == 0 ]] || fail "redaction failed"
fi
