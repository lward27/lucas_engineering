# prometheus-query-runner API Contracts

## HTTP API

Instant query:

```text
GET /api/v1/query?query=<promql>&time=<rfc3339-or-unix>
```

Range query:

```text
GET /api/v1/query_range?query=<promql>&start=<rfc3339-or-unix>&end=<rfc3339-or-unix>&step=<duration>
```

## Output Contract

```yaml
query: sum(rate(http_requests_total{namespace="apps-prod", app="finance-frontend", status=~"5.."}[5m]))
time_range:
  start: 2026-05-10T12:00:00-04:00
  end: 2026-05-10T12:15:00-04:00
  step: 30s
result_type: matrix
summary: No sustained 5xx traffic observed.
health_signal: pass
raw_result_ref: agent-skills/run-logs/example-prometheus-result.json
```
