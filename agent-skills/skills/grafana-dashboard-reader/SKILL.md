# grafana-dashboard-reader

## Purpose

Read Grafana dashboard metadata, panel summaries, and links for a deployment observation window.

This is a read-only skill. It complements PromQL and trace analysis by giving Codex the human dashboard view without changing dashboards or alerts.

## Trigger Conditions

- A deployment observation workflow needs dashboard evidence.
- Codex needs panel links for a final report.
- An alert or incident refers to a dashboard UID or panel.

## Inputs

- `grafana_base_url`
- `dashboard_uid`
- `namespace`
- `app`
- `from`
- `to`
- `variables`

## Outputs

```yaml
dashboard_uid: example
dashboard_title: Example Service
time_range:
  from: now-30m
  to: now
panels:
  - title: Error rate
    status: pass | warn | fail | unknown
    link: https://grafana.example/d/...
summary: short interpretation
health_signal: pass | warn | fail | unknown
```

## Tools and APIs

- Grafana HTTP API
- Grafana dashboard URLs
- `permission-checker`

## Required Permissions

Grafana read-only service account token or browser/session access with no edit rights.

## Safety Constraints

- Do not create, update, delete, or save dashboards.
- Do not expose Grafana API tokens.
- Do not rely on dashboard color alone; include panel title and time range.
- Return `unknown` when the dashboard is missing or variables do not match the app.

## Workflow

1. Confirm read-only observability permission.
2. Resolve the dashboard UID and variables.
3. Read dashboard metadata and construct panel links for the time window.
4. Summarize obvious warning/failure panels when data is accessible.
5. Return links and caveats for the final report.
