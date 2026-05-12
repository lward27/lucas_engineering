# permission-checker API Contracts

## Input Contract

```yaml
agent_id: hermes-observability
requested_action: read-prometheus-query
target_system: prometheus
target_namespace: apps-prod
target_repo: null
target_path: null
environment: apps-prod
tool_or_api: prometheus-http-api
```

## Output Contract

```yaml
decision: allow
reason: hermes-observability has hermes-readonly-observability grant for read-only observability APIs.
matched_agent: hermes-observability
matched_tool_grant: hermes-readonly-observability
required_approval_gate: null
audit_required: true
notes:
  - Read-only Prometheus access is permitted for apps-prod.
```

## Decision Values

- `allow`: Action is covered by the registry and does not require approval.
- `requires_approval`: Action is covered only after a human gate.
- `deny`: Action is not covered, is forbidden, or lacks enough context.
