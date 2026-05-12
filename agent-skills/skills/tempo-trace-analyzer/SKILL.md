# tempo-trace-analyzer

## Purpose

Analyze Tempo traces for post-deployment latency, errors, and downstream dependency failures.

This skill is read-only and should be used after metrics indicate slow requests, elevated error rates, or missing telemetry.

## Trigger Conditions

- Post-deployment p95/p99 latency increases.
- Error-rate queries show new failures.
- Codex has a trace ID from logs, alerts, or Grafana.
- `deployment-observer` needs trace evidence.

## Inputs

- `tempo_base_url`
- `service_name`
- `namespace`
- `app`
- `trace_id`
- `start_time`
- `end_time`
- `query`

## Outputs

```yaml
service_name: example
time_range: last_30m
trace_examples:
  - trace_id: abc123
    duration_ms: 1200
    root_status: error
    likely_bottleneck: downstream service
summary: short interpretation
health_signal: pass | warn | fail | unknown
```

## Tools and APIs

- Tempo query API
- Grafana Explore trace links
- `permission-checker`

## Required Permissions

Read-only Tempo access.

## Safety Constraints

- Do not dump full trace payloads into final reports.
- Avoid high-cardinality unbounded searches.
- Prefer representative traces with links.
- Treat missing traces as a telemetry gap, not proof of health.

## Workflow

1. Confirm read-only observability permission.
2. If a trace ID is provided, fetch it directly.
3. Otherwise search by service, namespace, app, status, and time window.
4. Identify slow spans, error spans, and downstream dependencies.
5. Return representative trace IDs and a short conclusion.
