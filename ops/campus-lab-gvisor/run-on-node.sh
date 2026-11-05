#!/usr/bin/env bash
# Run install-gvisor-node.sh on a Campus lab node from an operator
# workstation, through a short-lived privileged Pod in a temporary namespace.
# The namespace and Pod are always deleted on exit, so no privileged host-ops
# workload is left running.
#
#   ops/campus-lab-gvisor/run-on-node.sh [--context <ctx>] [--node <name>] [--check] [--allow-restart]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT="lucas_engineering"
NODE="ubuntu-lucas-engineering-2"
NAMESPACE="campus-lab-hostops"
LABEL_KEY="pharness.dev/campus-lab-runtime"
LABEL_VALUE="gvisor"
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --context) CONTEXT="$2"; shift 2 ;;
    --node) NODE="$2"; shift 2 ;;
    --check|--allow-restart) ARGS+=("$1"); shift ;;
    *) echo "usage: $0 [--context <ctx>] [--node <name>] [--check] [--allow-restart]" >&2; exit 2 ;;
  esac
done
[[ "$NODE" =~ ^[a-z0-9]([-a-z0-9.]*[a-z0-9])?$ ]] || { echo "invalid node name" >&2; exit 2; }

k() { kubectl --context "$CONTEXT" "$@"; }

cleanup() {
  k delete namespace "$NAMESPACE" --ignore-not-found --wait=true --timeout=120s >/dev/null 2>&1 || true
}
trap cleanup EXIT

sed "s/__NODE__/${NODE}/" "${SCRIPT_DIR}/hostops-pod.yaml" | k apply -f -
k -n "$NAMESPACE" wait --for=condition=Ready pod/campus-lab-hostops --timeout=120s >/dev/null

# The script is streamed to bash on the host; nothing is copied to disk.
set +e
k -n "$NAMESPACE" exec -i campus-lab-hostops -- \
  nsenter -t 1 -m -u -i -n -p -- bash -s -- "${ARGS[@]}" <"${SCRIPT_DIR}/install-gvisor-node.sh"
status=$?
if [[ "$status" == 4 ]]; then
  echo "waiting for k3s-agent on ${NODE} to restart"
  sleep 20
  k wait --for=condition=Ready "node/${NODE}" --timeout=300s >/dev/null
  k -n "$NAMESPACE" wait --for=condition=Ready pod/campus-lab-hostops --timeout=120s >/dev/null
  k -n "$NAMESPACE" exec -i campus-lab-hostops -- \
    nsenter -t 1 -m -u -i -n -p -- bash -s -- --check <"${SCRIPT_DIR}/install-gvisor-node.sh"
  status=$?
fi
set -e

check=false
for arg in "${ARGS[@]}"; do [[ "$arg" == --check ]] && check=true; done
current="$(k get node "$NODE" -o jsonpath="{.metadata.labels['${LABEL_KEY//./\\.}']}")"
if [[ "$current" == "$LABEL_VALUE" ]]; then
  echo "OK     node ${NODE} carries ${LABEL_KEY}=${LABEL_VALUE}"
elif [[ "$check" == true ]]; then
  echo "DRIFT  node ${NODE} lacks ${LABEL_KEY}=${LABEL_VALUE}"
  status=1
else
  k label node "$NODE" "${LABEL_KEY}=${LABEL_VALUE}" --overwrite
fi
exit "$status"
