#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SHARED_DIR="$SCRIPT_DIR/../../_shared/scripts"
CONTEXT=""
NAMESPACE="all"
LOOKBACK="30m"
OUTPUT_DIR=""
KUBECONFIG_OVERRIDE=""

usage() {
  cat <<'EOF'
Usage: collect-health.sh --context CONTEXT --output-dir DIR [--namespace NAME|all] [--lookback DURATION] [--kubeconfig FILE]

Collect bounded, sanitized cluster health evidence. This script is observation-only.
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
    --lookback) LOOKBACK=${2:-}; shift 2 ;;
    --output-dir) OUTPUT_DIR=${2:-}; shift 2 ;;
    --kubeconfig) KUBECONFIG_OVERRIDE=${2:-}; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n "$CONTEXT" ]] || fail "--context is required"
[[ -n "$OUTPUT_DIR" ]] || fail "--output-dir is required"
[[ -n "$NAMESPACE" ]] || fail "--namespace must not be empty"
[[ -x "$SHARED_DIR/context-guard.sh" ]] || fail "shared context guard is unavailable"
[[ -x "$SHARED_DIR/redact-output.sh" ]] || fail "shared redactor is unavailable"

guard=$("$SHARED_DIR/context-guard.sh" --context "$CONTEXT" --intent observation)
resolved_context=$(awk -F= '$1 == "resolved_context" { print $2 }' <<< "$guard")
profile_kubeconfig=$(awk -F= '$1 == "kubeconfig" { print $2 }' <<< "$guard")
[[ -n "$resolved_context" ]] || fail "context is not approved for this collector"
if [[ -n "$KUBECONFIG_OVERRIDE" ]]; then
  KUBECONFIG_PATH="$KUBECONFIG_OVERRIDE"
else
  KUBECONFIG_PATH="$profile_kubeconfig"
fi
[[ -r "$KUBECONFIG_PATH" ]] || fail "kubeconfig is not readable"

if [[ -e "$OUTPUT_DIR" ]] && [[ -n $(find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null) ]]; then
  fail "output directory must be empty"
fi
mkdir -p "$OUTPUT_DIR"

if [[ "$NAMESPACE" == "all" ]]; then
  SCOPE=(-A)
else
  SCOPE=(--namespace "$NAMESPACE")
fi
KUBECTL=(kubectl --kubeconfig "$KUBECONFIG_PATH" --context "$resolved_context" --request-timeout=20s)
COMMAND_LOG="$OUTPUT_DIR/commands.log"
CHECK_LOG="$OUTPUT_DIR/checks.tsv"
printf 'name\texit_code\n' > "$CHECK_LOG"

run_capture() {
  local name=$1
  shift
  printf '%q ' "$@" >> "$COMMAND_LOG"
  printf '\n' >> "$COMMAND_LOG"
  set +e
  "$@" 2>&1 | "$SHARED_DIR/redact-output.sh" --context "$resolved_context" > "$OUTPUT_DIR/$name.txt"
  local status=${PIPESTATUS[0]}
  set -e
  printf '%s\t%s\n' "$name" "$status" >> "$CHECK_LOG"
  return 0
}

run_capture version "${KUBECTL[@]}" version -o json
run_capture nodes "${KUBECTL[@]}" get nodes -o 'custom-columns=NAME:.metadata.name,READY:.status.conditions[?(@.type=="Ready")].status,VERSION:.status.nodeInfo.kubeletVersion' --no-headers
run_capture storageclasses "${KUBECTL[@]}" get storageclass -o 'custom-columns=NAME:.metadata.name,PROVISIONER:.provisioner,DEFAULT:.metadata.annotations.storageclass\.kubernetes\.io/is-default-class' --no-headers
run_capture workloads "${KUBECTL[@]}" get deployment,daemonset,statefulset "${SCOPE[@]}" -o 'custom-columns=KIND:.kind,NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.readyReplicas' --no-headers
run_capture nonrunning-pods "${KUBECTL[@]}" get pods "${SCOPE[@]}" --field-selector=status.phase!=Running -o 'custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,PHASE:.status.phase,REASON:.status.reason' --no-headers
run_capture warning-events "${KUBECTL[@]}" get events "${SCOPE[@]}" --field-selector=type=Warning --sort-by=.lastTimestamp -o 'custom-columns=LAST:.lastTimestamp,NAMESPACE:.metadata.namespace,REASON:.reason,OBJECT:.involvedObject.name,MESSAGE:.message' --no-headers
run_capture platform-crds "${KUBECTL[@]}" get crd -o name

for bounded_file in nonrunning-pods.txt warning-events.txt; do
  if [[ -f "$OUTPUT_DIR/$bounded_file" ]]; then
    tail -n 200 "$OUTPUT_DIR/$bounded_file" > "$OUTPUT_DIR/$bounded_file.bounded"
    mv "$OUTPUT_DIR/$bounded_file.bounded" "$OUTPUT_DIR/$bounded_file"
  fi
done

node_not_ready=$(awk '$2 != "True" && NF >= 2 { count++ } END { print count + 0 }' "$OUTPUT_DIR/nodes.txt")
nonrunning_count=$(awk 'NF { count++ } END { print count + 0 }' "$OUTPUT_DIR/nonrunning-pods.txt")
failed_checks=$(awk -F '\t' 'NR > 1 && $2 != 0 { count++ } END { print count + 0 }' "$CHECK_LOG")
status="healthy"
if ((node_not_ready > 0)); then
  status="critical"
elif ((nonrunning_count > 0 || failed_checks > 0)); then
  status="degraded"
fi

if command -v jq >/dev/null 2>&1; then
  jq -n \
    --arg status "$status" \
    --arg context "$resolved_context" \
    --arg namespace "$NAMESPACE" \
    --arg lookback "$LOOKBACK" \
    --argjson node_not_ready "$node_not_ready" \
    --argjson nonrunning_pods "$nonrunning_count" \
    --argjson failed_checks "$failed_checks" \
    '{status: $status, context: $context, namespace: $namespace, lookback: $lookback, node_not_ready: $node_not_ready, nonrunning_pods: $nonrunning_pods, failed_checks: $failed_checks}' > "$OUTPUT_DIR/summary.json"
else
  printf '{"status":"%s","context":"%s","namespace":"%s","lookback":"%s"}\n' "$status" "$resolved_context" "$NAMESPACE" "$LOOKBACK" > "$OUTPUT_DIR/summary.json"
fi

cat > "$OUTPUT_DIR/SUMMARY.md" <<EOF
# Cluster Health Summary

- Status: $status
- Context: $resolved_context
- Namespace scope: $NAMESPACE
- Observation window: $LOOKBACK
- Not Ready nodes: $node_not_ready
- Non-running pods reported: $nonrunning_count
- Failed collection checks: $failed_checks

## Evidence

- \`nodes.txt\`, \`storageclasses.txt\`, \`workloads.txt\`, \`nonrunning-pods.txt\`, and \`warning-events.txt\` contain bounded Kubernetes metadata.
- \`platform-crds.txt\` records installed API extensions without reading custom-resource content.
- \`commands.log\` contains sanitized, explicit-context commands.

## Missing Visibility

- Metrics, logs, traces, Hubble flows, GitOps status, and Tekton status require a specifically scoped follow-up when relevant.
- A non-zero collection check means that signal is unavailable, not necessarily unhealthy.
EOF

printf '%s\n' "$OUTPUT_DIR"
