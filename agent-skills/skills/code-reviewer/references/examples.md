# code-reviewer Examples

## Blocking Finding

```yaml
findings:
  - severity: P1
    file: charts/example/templates/deployment.yaml
    line: 42
    issue: The deployment references a mutable latest tag for a live rollout.
    recommendation: Use the immutable digest produced by the build.
approval_recommendation: block
```

## Request Changes

```yaml
findings:
  - severity: P2
    file: cluster/rbac/example.yaml
    line: 18
    issue: The role grants secrets/list to a general agent.
    recommendation: Remove secret read verbs and use a scoped secret reference workflow.
approval_recommendation: request_changes
```
