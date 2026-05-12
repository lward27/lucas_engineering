# argocd-health-check API Contracts

## Input Contract

```yaml
argocd_app: hermes-agent
namespace: hermes-agent
expected_revision: HEAD
expected_image_digest: null
observation_window: 10m
environment: apps-prod
```

## Output Contract

```yaml
app: hermes-agent
namespace: hermes-agent
sync_status: Synced
health_status: Healthy
revision: abc123
resources:
  - kind: StatefulSet
    name: hermes-agent
    health: Healthy
kubernetes_summary:
  ready: true
  warnings: []
recommendation: pass
```
