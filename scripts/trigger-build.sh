#!/usr/bin/env bash
# trigger-build.sh — manually trigger a Tekton clone-build-push PipelineRun
#
# Usage:
#   ./scripts/trigger-build.sh <service>
#   ./scripts/trigger-build.sh all
#
# Examples:
#   ./scripts/trigger-build.sh finance-app-db-service
#   ./scripts/trigger-build.sh finance-frontend
#   ./scripts/trigger-build.sh yfinance-wrapper
#   ./scripts/trigger-build.sh scraper-manager
#   ./scripts/trigger-build.sh all

set -euo pipefail

NAMESPACE="tekton-pipelines"

# ── service definitions ─────────────────────────────────────────────────────
declare -A REPO_URL IMAGE_REF STORAGE

REPO_URL[finance-app-db-service]="https://github.com/lward27/finance-app-db-service.git"
IMAGE_REF[finance-app-db-service]="registry.lucas.engineering/finance-app-db-service:latest"
STORAGE[finance-app-db-service]="1Gi"

REPO_URL[finance-app-database-service]="https://github.com/lward27/finance_app_database_service.git"
IMAGE_REF[finance-app-database-service]="registry.lucas.engineering/finance_app_database_service:latest"
STORAGE[finance-app-database-service]="1Gi"

REPO_URL[finance-frontend]="https://github.com/lward27/finance-frontend.git"
IMAGE_REF[finance-frontend]="registry.lucas.engineering/finance-frontend:latest"
STORAGE[finance-frontend]="1Gi"

REPO_URL[yfinance-wrapper]="https://github.com/lward27/yfinance_wrapper.git"
IMAGE_REF[yfinance-wrapper]="registry.lucas.engineering/yfinance_wrapper:latest"
STORAGE[yfinance-wrapper]="1Gi"

REPO_URL[scraper-manager]="https://github.com/lward27/scraper_manager.git"
IMAGE_REF[scraper-manager]="registry.lucas.engineering/scraper_manager:latest"
STORAGE[scraper-manager]="1Gi"

ALL_SERVICES=(finance-app-db-service finance-app-database-service finance-frontend yfinance-wrapper scraper-manager)

# ── helpers ─────────────────────────────────────────────────────────────────
usage() {
  echo "Usage: $0 <service|all>"
  echo ""
  echo "Services:"
  for svc in "${ALL_SERVICES[@]}"; do
    echo "  $svc"
  done
  exit 1
}

trigger() {
  local svc="$1"
  if [[ -z "${REPO_URL[$svc]+x}" ]]; then
    echo "ERROR: unknown service '$svc'" >&2
    usage
  fi

  echo "▶ Triggering build for: $svc"
  echo "  repo:  ${REPO_URL[$svc]}"
  echo "  image: ${IMAGE_REF[$svc]}"

  kubectl create -n "$NAMESPACE" -f - <<MANIFEST
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: ${svc}-run-
  namespace: ${NAMESPACE}
  labels:
    app.kubernetes.io/part-of: tekton-ci
    app.kubernetes.io/component: ${svc}
spec:
  pipelineRef:
    name: clone-build-push
  workspaces:
    - name: shared-data
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: ${STORAGE[$svc]}
  params:
    - name: repo-url
      value: "${REPO_URL[$svc]}"
    - name: image-reference
      value: "${IMAGE_REF[$svc]}"
    - name: kaniko-extra-args
      value:
        - --skip-tls-verify
MANIFEST

  local run_name
  run_name=$(kubectl get pipelinerun -n "$NAMESPACE" -l "app.kubernetes.io/component=${svc}" \
    --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}' 2>/dev/null || echo "")

  echo ""
  echo "  ✓ PipelineRun created. To watch progress:"
  echo "    kubectl get pipelinerun -n $NAMESPACE -w"
  if [[ -n "$run_name" ]]; then
    echo "    kubectl logs -n $NAMESPACE -l tekton.dev/pipelineRun=${run_name} --all-containers -f"
  fi
  echo ""
}

# ── main ─────────────────────────────────────────────────────────────────────
[[ $# -lt 1 ]] && usage

TARGET="${1}"

if [[ "$TARGET" == "all" ]]; then
  for svc in "${ALL_SERVICES[@]}"; do
    trigger "$svc"
  done
else
  trigger "$TARGET"
fi
