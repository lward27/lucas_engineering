# prometheus-query-runner

## Purpose

Run bounded PromQL queries and summarize the result for deployment health, incident triage, and post-deployment observation.

This is a read-only observability skill.

## Trigger Conditions

- Deployment verification needs golden signal metrics.
- An alert or regression needs metric evidence.
- Codex asks for pre-deploy versus post-deploy comparison.
- `deployment-observer` needs Prometheus or Mimir data.

## Inputs

- `prometheus_base_url`
- `query`
- `start_time`
- `end_time`
- `step`
- `namespace`
- `app`
- `deployment_revision`
- `reason`

## Outputs

```yaml
query: original PromQL
time_range: start/end/step
result_type: vector | matrix | scalar | string
summary: concise interpretation
raw_result_ref: path or link
health_signal: pass | warn | fail | unknown
notes:
  - limitation or caveat
```

## Tools and APIs

- Prometheus HTTP API
- Mimir query API when long-retention data is needed
- `permission-checker`
- `references/promql-library.md`
- Helper script: `scripts/prometheus-query.rb`

## Required Permissions

Read-only Prometheus or Mimir query access. No Kubernetes mutation and no secret value exposure.

## Safety Constraints

- Query windows must be bounded.
- Prefer low-cardinality label filters.
- Avoid unbounded `{}` queries.
- Do not query secret labels or dump high-cardinality raw series into final reports.
- Use `permission-checker` before querying non-sandbox environments.

## Workflow

1. Confirm the caller has read-only observability permission.
2. Validate the query has namespace/app scoping when applicable.
3. Bound the time range and step.
4. Execute the query.
5. Summarize the result against the requested health signal.
6. Store or link raw results when useful.
7. Return pass/warn/fail/unknown with caveats.

## Example Invocation

```text
Run the post-deploy error-rate query for finance-frontend in apps-prod for the last 15 minutes.
```

## Helper Script

```bash
ruby agent-skills/skills/prometheus-query-runner/scripts/prometheus-query.rb \
  --base-url http://localhost:9090 \
  --query 'up{namespace="hermes-agent"}'
```
