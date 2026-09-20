# argocd-health-check API Contracts

## Input Contract

```yaml
argocd_app: <application-name>
namespace: <namespace>
expected_revision: HEAD
expected_image_digest: null
observation_window: 10m
environment: <environment>
```

## Output Contract

```yaml
app: <application-name>
namespace: <namespace>
sync_status: Synced
health_status: Healthy
revision: abc123
resources: []
kubernetes_summary:
  ready: true
  warnings: []
recommendation: pass
```
