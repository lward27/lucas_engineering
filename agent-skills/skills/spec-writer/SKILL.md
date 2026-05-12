# spec-writer

## Purpose

Create an implementation-ready specification for non-trivial changes.

Specs should live in `docs/specs/` unless the user requests another location. They must include acceptance criteria, non-goals, test expectations, rollout notes, approval gates, and rollback expectations.

## Trigger Conditions

- A change spans source code and GitOps manifests.
- A change requires multiple agents.
- A change affects live deployment, RBAC, secrets, observability, or CI/CD.

## Inputs

- Goal brief
- Clarified requirements
- Repo analysis
- Architecture review notes
- Risk assessment

## Outputs

```yaml
spec_path: docs/specs/<slug>.md
title: short title
acceptance_criteria: []
non_goals: []
implementation_notes: []
test_plan: []
rollout_plan: []
rollback_plan: []
approval_gates: []
```

## Safety Constraints

- Do not hide unknowns.
- Call out direct cluster mutation as a non-default path.
- Include rollback criteria for deployments.
- Include observability checks as part of acceptance.

## Suggested Spec Template

```markdown
# Title

## Goal
## Non-Goals
## Requirements
## Acceptance Criteria
## Implementation Plan
## Test Plan
## Rollout Plan
## Rollback Plan
## Observability Checks
## Approval Gates
```
