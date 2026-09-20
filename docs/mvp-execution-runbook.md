# Read-Only MVP Execution Runbook

Date: 2026-05-10

This runbook launches the first safe MVP: desktop-hosted Hermes, Kubernetes ingress/front door, read-only cluster observation, and post-deploy health checks. It does not enable build, image publish, Argo sync automation, or rollback automation.

## Current MVP Scope

Allowed:

- validate agent registry and skill catalog
- render and lint the `agentic-platform` chart
- enable the `agentic-platform` Argo app
- grant Hermes read-only observer RBAC
- generate a short-lived desktop kubeconfig for Hermes if needed
- read Argo CD Application health through Kubernetes
- run bounded Prometheus/Mimir-style queries
- produce read-only deployment observation reports

Not included yet:

- Tekton build triggering
- registry publication
- GitHub PR automation
- Argo CD sync automation
- rollback automation
- secret value access

## Prerequisites

- `kubectl` points at the `lucas_engineering` cluster.
- `helm`, `ruby`, `curl`, and `jq` are installed.
- Root app is managed by Argo CD.
- Desktop Hermes has its API server enabled.
- Desktop Hermes authentication is managed outside this Kubernetes GitOps repository.

## Step 1: Local Readiness

```bash
ruby agent-skills/scripts/mvp-readiness.rb
```

Expected:

```text
ready_for_local_dry_run: true
ready_for_cluster_mvp_execution_after_approval: true
```

## Step 2: Render Review

```bash
helm template agentic-platform charts/agentic-platform --namespace agent-runtime
```

Review:

- namespaces
- network policies

## Step 3: Commit And Push GitOps Changes

`apps.agentic-platform.enabled` should be `true`:

```yaml
apps:
  agentic-platform:
    enabled: true
```

Then commit and push the GitOps change.

## Step 4: Argo Reconciliation

Wait for root app to create the `agentic-platform` Application.

Read-only checks:

```bash
kubectl get application agentic-platform -n argocd -o wide
kubectl get application agentic-platform -n argocd -o jsonpath='{.status.sync.status}{" "}{.status.health.status}{"\n"}'
```

## Step 5: Desktop Hermes Authentication

The desktop Hermes process must use its local kubeconfig or another separately managed identity. This repository no longer provisions a Kubernetes Hermes service account or generates a service-account kubeconfig.

## Step 6: Metrics Helper Test

Use a reachable Prometheus or Mimir URL. For a local port-forward:

```bash
kubectl -n monitoring port-forward svc/prometheus-server 9090:80
```

Then:

```bash
ruby agent-skills/skills/prometheus-query-runner/scripts/prometheus-query.rb \
  --base-url http://localhost:9090 \
  --query 'up'
```

For app-specific checks, use scoped queries from:

```text
agent-skills/skills/prometheus-query-runner/references/promql-library.md
```

## MVP Success Criteria

- Foundation validation passes.
- `agentic-platform` Argo app is synced and healthy.
- Desktop Hermes remains reachable through its separately managed API endpoint.
- Prometheus query helper returns a bounded result.
- No live build, publish, sync, or rollback automation is enabled.

## Network and Runtime Notes

Hermes runs on the desktop host and dispatch targets its desktop API directly. The Kubernetes Service, EndpointSlice, Ingress, namespace, read-only observer RBAC, and service-account kubeconfig helper were retired.
