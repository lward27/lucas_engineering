# otel-signal-reviewer

## Purpose

Verify that a service emits useful OpenTelemetry signals with the labels and resource attributes required for deployment observation.

This skill is read-only and focuses on telemetry completeness, not application correctness.

## Trigger Conditions

- A new service is deployed.
- Metrics or traces are missing from dashboards.
- A deployment report needs telemetry coverage notes.
- A service changed OTEL collector, SDK, or instrumentation config.

## Inputs

- `app`
- `namespace`
- `service_name`
- `deployment_revision`
- `time_range`
- `required_attributes`

## Outputs

```yaml
service_name: example
metrics_present: true
traces_present: true
logs_present: unknown
required_attributes:
  service.name: present
  k8s.namespace.name: present
  service.version: missing
gaps:
  - service.version missing from traces
recommendation: pass | warn | fail | unknown
```

## Tools and APIs

- Prometheus/Mimir queries
- Tempo service and trace queries
- Grafana dashboard links
- OTEL collector config review when available

## Required Permissions

Read-only observability and repo access.

## Safety Constraints

- Do not change collector configuration.
- Do not add instrumentation code.
- Do not expose log payloads that may include sensitive data.
- Missing telemetry should be reported as a deployment quality gap.

## Required Attributes

- `service.name`
- `service.version` or image digest label
- `k8s.namespace.name`
- `k8s.pod.name`
- `deployment.environment`
