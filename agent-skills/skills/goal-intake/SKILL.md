# goal-intake

## Purpose

Normalize a high-level user goal into a delivery brief that Codex can route to planning, coding, GitOps, deployment, or observability workflows.

## Trigger Conditions

- A user asks Codex to build, change, deploy, debug, observe, or roll back software.
- A request mentions an app under `/Users/wardl/Personal/apps`.
- A request mentions GitOps, Argo CD, Tekton, registry, Hermes, observability, or cluster state.

## Inputs

- User prompt
- Current working directory
- Known app names under `/Users/wardl/Personal/apps`
- GitOps repo path `/Users/wardl/Personal/lucas_engineering`
- Any stated environment, risk, or approval constraints

## Outputs

```yaml
goal: short objective
goal_type: feature | bugfix | deployment | observability | rollback | planning | unknown
target_app: optional app name
source_repo: optional /Users/wardl/Personal/apps path
gitops_repo: /Users/wardl/Personal/lucas_engineering
environment: sandbox | apps | apps-prod | unknown
constraints: []
unknowns: []
risk_hint: low | medium | high | critical | unknown
recommended_next_skill: requirements-clarifier | repo-analyzer | argocd-health-check | deployment-observer
```

## Safety Constraints

- Do not infer a live environment when the prompt is ambiguous.
- Preserve explicit user constraints exactly.
- If an app or environment cannot be identified, return `unknown` and ask for clarification.
- Do not grant permissions or run mutation steps.

## Workflow

1. Extract the requested outcome.
2. Identify target app, source repo, and GitOps chart if possible.
3. Classify the request type and risk hint.
4. Capture constraints and unknowns.
5. Recommend the next skill.

## Example Invocation

```text
Turn "ship the new finance frontend image through GitOps" into a goal brief.
```
