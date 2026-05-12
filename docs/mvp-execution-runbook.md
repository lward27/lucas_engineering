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
- `charts/agentic-platform` has been reviewed.
- `charts/hermes-agent` is in `external` runtime mode and points at the desktop Hermes host.
- Desktop Hermes has its API server enabled.

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
- `hermes-readonly-observer` ClusterRole
- `hermes-agent-readonly-observer` ClusterRoleBinding
- no-secret-read guardrail note
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

## Step 5: RBAC Verification

```bash
kubectl auth can-i get pods --as=system:serviceaccount:hermes-agent:hermes-agent --all-namespaces
kubectl auth can-i list applications.argoproj.io --as=system:serviceaccount:hermes-agent:hermes-agent -n argocd
kubectl auth can-i get secrets --as=system:serviceaccount:hermes-agent:hermes-agent --all-namespaces
```

Expected:

- `get pods`: yes
- `list applications.argoproj.io`: yes
- `get secrets`: no

## Step 6: Generate Desktop Hermes Kubeconfig

After `agentic-platform` is synced, generate a short-lived kubeconfig for desktop Hermes:

```bash
ruby agent-skills/scripts/generate-desktop-hermes-kubeconfig.rb \
  --output /tmp/hermes-desktop.kubeconfig \
  --duration 24h
```

Copy that file to the desktop Hermes host and set Hermes/Codex shell tooling to use it as `KUBECONFIG`.

Do not commit this file. It contains a bearer token.

## Step 7: Health Helper Test

```bash
ruby agent-skills/skills/argocd-health-check/scripts/argocd-health-check.rb \
  --app hermes-agent \
  --namespace hermes-agent
```

Expected:

- JSON report
- no mutation
- recommendation is `pass`, `wait`, or `investigate`

## Step 8: Metrics Helper Test

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
- Hermes service account can read workload and Argo health data.
- Hermes service account cannot read Secrets.
- Argo health helper returns a report for `hermes-agent`.
- Prometheus query helper returns a bounded result.
- No live build, publish, sync, or rollback automation is enabled.

## External Hermes Notes

Hermes now runs on the desktop host, not as a Kubernetes pod. Kubernetes resources do not inject config into the desktop process automatically.

The interaction model is:

- `charts/hermes-agent` exposes the desktop Hermes service through Kubernetes Service, EndpointSlice, and Ingress.
- `charts/agentic-platform` grants a Kubernetes ServiceAccount read-only observer permissions.
- `generate-desktop-hermes-kubeconfig.rb` creates a short-lived kubeconfig for the desktop process to use.
- Hermes API orchestration targets the desktop API URL configured in the agent registry.
