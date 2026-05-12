# requirements-clarifier

## Purpose

Identify missing requirements and decide whether Codex can proceed with safe assumptions or must ask the user.

## Trigger Conditions

- `goal-intake` returns unknowns.
- The target app, environment, rollout expectation, or acceptance criteria are unclear.
- A task may affect live workloads, data, secrets, or user-facing behavior.

## Inputs

- Goal brief
- Repo and chart mapping
- Existing docs or issue context
- User-stated constraints

## Outputs

```yaml
clarified_requirements: []
assumptions: []
questions: []
blocked: false
safe_to_continue: true
recommended_next_skill: spec-writer | repo-analyzer | approval-gate-manager
```

## Safety Constraints

- Ask only necessary questions.
- Prefer safe assumptions for low-risk docs or read-only work.
- Require clarification for live deployment targets, destructive changes, secret use, or data migrations.

## Workflow

1. Compare the goal brief to the information needed for the next step.
2. List assumptions Codex can safely make.
3. List questions that block safe progress.
4. Set `blocked` only when proceeding would be risky.

## Example Invocation

```text
Clarify requirements for deploying finance-frontend to apps-prod through GitOps.
```
