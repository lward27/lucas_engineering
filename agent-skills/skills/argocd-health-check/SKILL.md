# argocd-health-check

## Purpose

Read Argo CD and Kubernetes state for an application and produce a deployment health report.

This skill is read-only unless it is explicitly paired with `argocd-sync` or `deployment-rollback` after approval.

## Trigger Conditions

- Before a release, to confirm current app state.
- After Argo sync, to confirm health.
- During incident triage, to identify sync drift, degraded resources, or failed rollouts.
- Before rollback, to capture the failed state.

## Inputs

- `argocd_app`
- `namespace`
- `expected_revision`
- `expected_image_digest`
- `observation_window`
- `environment`

## Outputs

```yaml
app: hermes-agent
sync_status: Synced | OutOfSync | Unknown
health_status: Healthy | Progressing | Degraded | Missing | Unknown
revision: git revision
resources:
  - kind: Deployment
    name: example
    health: Healthy
kubernetes_summary:
  ready: true
  warnings: []
recommendation: pass | wait | investigate | rollback
```

## Tools and APIs

- Argo CD API or CLI in read-only mode
- Kubernetes API read-only checks
- `kubectl get`, `kubectl describe`, pod events, and pod logs when permitted
- `permission-checker`
- Helper script: `scripts/argocd-health-check.rb`

## Required Permissions

Read-only access to the Argo app and related Kubernetes namespace. No direct mutation.

## Safety Constraints

- Do not sync, refresh, terminate, delete, or patch resources.
- Do not read secret values from Kubernetes Secrets.
- Treat `OutOfSync`, `Degraded`, and repeated restarts as blockers for final success.
- Include exact app name and namespace in the report.

## Workflow

1. Confirm read permission with `permission-checker`.
2. Read Argo app sync and health status.
3. Check target revision and image digest when provided.
4. Inspect workload readiness, pods, services, ingress, events, and recent warning logs.
5. Classify the deployment as pass, wait, investigate, or rollback.
6. Return evidence and next recommended action.

## Example Invocation

```text
Check Argo CD health for hermes-agent in namespace hermes-agent and report whether it is synced and healthy.
```

## Helper Script

```bash
ruby agent-skills/skills/argocd-health-check/scripts/argocd-health-check.rb \
  --app hermes-agent \
  --namespace hermes-agent
```
