# approval-gate-manager

## Purpose

Decide whether a workflow action needs human approval and produce the approval request text.

This skill does not approve actions. It classifies gates, records the reason, and tells Codex what evidence must be shown before the user approves or denies the action.

## Trigger Conditions

- `permission-checker` returns `requires_approval`.
- A workflow wants to merge a PR, publish a non-sandbox image, update live GitOps manifests, sync Argo CD, access secret references, or roll back a live app.
- A requested action is destructive, irreversible, or production-like.

## Inputs

- `action`
- `actor`
- `target`
- `environment`
- `risk_level`
- `evidence`
- `rollback_plan`
- `approval_policy`

## Outputs

```yaml
gate_id: release-live-gitops-update
decision: approval_required | no_approval_required | forbidden
approval_prompt: text to show user
required_evidence:
  - tests
  - diff
  - rollback
audit_required: true
expires_after: optional duration
```

## Tools and APIs

- `docs/master-plan.md`
- `agent-skills/agents/registry/tool-grants.yaml`
- Run artifacts and test summaries
- Optional audit log writer

## Required Permissions

Read-only policy and artifact access. Write access only to run logs or approval records.

## Safety Constraints

- Approval requests must be specific to one action.
- Do not bundle unrelated risky actions into one approval.
- Do not ask for approval to expose raw secret values to general-purpose agents.
- If rollback evidence is required and missing, return `forbidden` or request missing evidence.

## Workflow

1. Classify the action by risk.
2. Match the action to a gate category.
3. Check that required evidence exists.
4. Generate a human-readable approval prompt.
5. Record the gate decision and evidence requirements.
6. Return the gate result to Codex.

## Gate Categories

| Gate | Applies to |
| --- | --- |
| `spec-approval` | Multi-step or ambiguous feature specs |
| `release-approval` | Live image publication, GitOps manifest update, Argo sync |
| `secret-approval` | Any secret reference grant |
| `destructive-approval` | Deletes, database changes, PVC changes |
| `rollback-approval` | Live rollback outside pre-approved emergency policy |

## Example Invocation

```text
Create an approval gate for syncing the finance-frontend Argo app to a new image digest in apps-prod.
```
