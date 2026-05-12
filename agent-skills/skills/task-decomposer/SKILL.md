# task-decomposer

## Purpose

Break an approved spec into bounded tasks that can be assigned to Hermes agents without overlapping ownership or unsafe parallelism.

## Trigger Conditions

- A spec has been approved or accepted.
- Codex needs to delegate work to planning, review, observability, or GitOps agents.
- A task touches multiple repos or cluster services.

## Inputs

- Spec
- Repo analysis
- Agent registry
- Permission model
- Risk assessment

## Outputs

```yaml
tasks:
  - id: task-001
    title: short title
    owner_agent: hermes-planning | hermes-reviewer | hermes-observability | hermes-gitops-release
    skills: []
    files_or_paths: []
    dependencies: []
    approval_required: false
    done_when: []
parallel_groups:
  - [task-001, task-002]
```

## Safety Constraints

- Do not assign overlapping write paths to parallel tasks.
- Do not assign deploy/sync tasks before review and approval tasks.
- Do not assign secret handling to general-purpose agents.

## Workflow

1. Identify independent work streams.
2. Assign each task to a single agent.
3. Define file/path ownership.
4. Mark approval gates.
5. Sequence build, GitOps, deployment, and observation tasks.
