# GitOps Workflow

Date: 2026-05-10

This repo uses an app-of-apps model. `charts/root-app` registers Argo CD Applications, and each deployed service has its own wrapper chart under `charts/<app>/`.

## Current Layout

```text
/Users/wardl/Personal/
  apps/
    <application-source-repo>/
  lucas_engineering/
    charts/
      root-app/
        values.yaml
        templates/<app>.yaml
      <app>/
    agent-skills/
    cluster/
    docs/
```

## Phase 1 Release Rule

Hermes agents may propose GitOps changes, but they must not merge, sync, or mutate live cluster resources without approval.

## Add a New GitOps App

1. Create `charts/<app>/Chart.yaml`.
2. Create `charts/<app>/values.yaml`.
3. Create templates for deployment, service, ingress, RBAC, and network policy as needed.
4. Add `charts/root-app/templates/<app>.yaml`.
5. Add `apps.<app>.enabled: false` to `charts/root-app/values.yaml` by default.
6. Render with `helm template`.
7. Use `change-risk-assessor`.
8. Use `approval-gate-manager` before enabling or syncing live.

## Update an Existing App Image

1. Confirm source repo under `/Users/wardl/Personal/apps/<app>`.
2. Run or inspect tests.
3. Build image through approved CI path.
4. Record immutable image digest.
5. Update `charts/<app>/values.yaml`.
6. Render chart.
7. Open GitOps PR.
8. After approval and merge, sync Argo CD.
9. Run `deployment-observer`.

## Agentic Platform Chart

`charts/agentic-platform` contains the GitOps-ready version of the foundation cluster resources:

- namespaces
- Hermes read-only observer RBAC
- no-secret-read guardrail note
- agent runtime network policy scaffolding
- read-only RBAC for the desktop Hermes kubeconfig identity

It is registered in root-app as `agentic-platform` and enabled for the MVP:

```yaml
apps:
  agentic-platform:
    enabled: true
```

Keep mutation-oriented build, sync, publish, and rollback automation disabled until the read-only MVP has been tested.

## Required Evidence for Live Changes

- Git diff
- Helm render output
- risk assessment
- approval gate
- rollback revision or previous digest
- post-deploy observation plan
