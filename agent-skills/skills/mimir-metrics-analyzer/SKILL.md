# mimir-metrics-analyzer

## Purpose

Use Mimir long-retention metrics to compare post-deployment behavior against a baseline window.

This skill is read-only and should be used when a short Prometheus window is not enough to decide whether a deployment changed behavior.

## Trigger Conditions

- A deployment needs before/after comparison.
- Codex needs a baseline from yesterday, last week, or a prior release.
- Prometheus local retention is insufficient.

## Inputs

- `mimir_base_url`
- `namespace`
- `app`
- `baseline_start`
- `baseline_end`
- `comparison_start`
- `comparison_end`
- `queries`

## Outputs

```yaml
app: example
baseline_window: 2026-05-09T12:00:00-04:00/2026-05-09T12:30:00-04:00
comparison_window: 2026-05-10T12:00:00-04:00/2026-05-10T12:30:00-04:00
comparisons:
  - metric: error_rate
    baseline: 0.001
    comparison: 0.003
    status: warn
summary: short trend interpretation
health_signal: pass | warn | fail | unknown
```

## Tools and APIs

- Mimir/Prometheus-compatible query API
- `prometheus-query-runner` query library
- `permission-checker`

## Required Permissions

Read-only Mimir query access.

## Safety Constraints

- Always bound baseline and comparison windows.
- Avoid unscoped high-cardinality queries.
- Do not treat absent historical data as a pass.
- Preserve raw query output as a reference, not inline in long reports.
