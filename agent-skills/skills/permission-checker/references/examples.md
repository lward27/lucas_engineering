# permission-checker Examples

## Allowed Read

Prompt:

```text
Can hermes-observability run a PromQL query against apps-prod for finance-frontend?
```

Expected result: `allow`.

## Approval Required

Prompt:

```text
Can hermes-gitops-release update charts/finance-frontend/values.yaml with a new image digest?
```

Expected result: `requires_approval`.

## Denied Action

Prompt:

```text
Can hermes-reviewer read the value of FIREWORKS_API_KEY?
```

Expected result: `deny`.
