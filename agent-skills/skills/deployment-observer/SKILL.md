# deployment-observer

## Purpose

Run the post-deployment observation checklist by combining Argo CD, Kubernetes, Prometheus, Mimir, Tempo, Grafana, and OTEL evidence.

This skill is read-only. It does not sync, patch, delete, restart, or roll back. It tells Codex whether the deployment should pass, wait, be investigated, or move to a rollback approval gate.

## Trigger Conditions

- After Argo CD reports a successful sync.
- During the observation window after a deployment.
- When Codex needs health evidence before final report.
- When an alert fires after a release.

## Inputs

- `app`
- `namespace`
- `argocd_app`
- `deployment_timestamp`
- `observation_window`
- `expected_revision`
- `expected_image_digest`
- `slo_profile`

## Output Contract

```yaml
app: example
namespace: apps-prod
observation_window: 30m
checks:
  - name: argo-health
    result: pass | warn | fail | unknown
    evidence: short note or link
recommendation: pass | wait | investigate | rollback
```

## Tools and APIs

- `argocd-health-check`
- `prometheus-query-runner`
- `grafana-dashboard-reader`
- `tempo-trace-analyzer`
- `mimir-metrics-analyzer`
- `otel-signal-reviewer`
- Kubernetes read-only API

## Required Permissions

Read-only Argo CD, Kubernetes, Grafana, Prometheus/Mimir, and Tempo access for the target app and namespace.

## Safety Constraints

- Do not mutate the cluster.
- Do not read Kubernetes Secret values.
- Do not declare success if Argo is degraded, pods are not ready, or critical alerts are firing.
- If telemetry is missing, return `warn` or `unknown`, not a clean `pass`.
- If rollback is recommended, route to `approval-gate-manager`.

## Checklist

| Check | Pass condition |
| --- | --- |
| Argo sync | App is synced to expected revision |
| Argo health | App is healthy |
| Workload readiness | Expected pods are ready |
| Ingress/service | Endpoint responds as expected |
| Error rate | 5xx/application error rate is within SLO |
| Latency | p95/p99 are within SLO or baseline |
| Restarts | No unexplained restart increase |
| Saturation | CPU/memory/disk are within safe bounds |
| Traces | Key paths emit traces |
| Metrics | Required labels are present |
| Alerts | No new critical alerts |
| Rollback readiness | Previous revision/digest is known |

## Recommendation Rules

- `pass`: All required checks pass and telemetry is present.
- `wait`: Rollout is progressing inside the expected window.
- `investigate`: Health is degraded, telemetry is missing, or signals conflict.
- `rollback`: User-visible errors, failed readiness, or critical alerts persist beyond the tolerance window.
