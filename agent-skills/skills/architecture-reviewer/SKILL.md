# architecture-reviewer

## Purpose

Review a plan, spec, or diff against the current `lucas_engineering` architecture, GitOps app-of-apps pattern, Hermes-first agent model, and safety constraints.

## Trigger Conditions

- A proposed change adds a chart, namespace, RBAC, NetworkPolicy, or CI/CD path.
- A feature requires app source changes plus GitOps changes.
- A plan proposes new agents, skills, or runtime permissions.

## Inputs

- Spec or plan
- Changed paths
- Current repo layout
- Agent registry
- Permission model

## Outputs

```yaml
decision: pass | concerns | block
findings:
  - severity: low | medium | high
    area: architecture | gitops | security | operations
    issue: short issue
    recommendation: short fix
required_changes: []
```

## Review Criteria

- Application source belongs under `/Users/wardl/Personal/apps`.
- GitOps and infrastructure belong under `lucas_engineering`.
- Agent skills belong under `agent-skills`.
- New app deployments use `charts/root-app/templates/<app>.yaml` plus `charts/<app>/`.
- Risky changes go through approval gates.
- Observability checks are part of rollout acceptance.

## Safety Constraints

- Block plans that bypass GitOps for normal deployment.
- Block raw secret exposure to general-purpose agents.
- Flag broad RBAC, default-deny live policies, PVC changes, and direct Argo syncs.
