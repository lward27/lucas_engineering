# permission-checker

## Purpose

Verify whether a requested agent action is allowed before the action is attempted.

Use this skill whenever Codex or a Hermes agent is about to read from a protected system, write to the repo, trigger a build, update GitOps manifests, sync Argo CD, access a secret reference, or perform any Kubernetes action.

## Trigger Conditions

- An agent requests a tool grant.
- A workflow step changes from planning to execution.
- A task touches Kubernetes, GitHub, registry, Argo CD, observability APIs, or secrets.
- A requested action is not clearly covered by the agent registry.

## Inputs

- `agent_id`
- `requested_action`
- `target_system`
- `target_namespace`
- `target_repo`
- `target_path`
- `environment`
- `tool_or_api`
- `risk_level` if already known

## Outputs

Return a concise decision:

```yaml
decision: allow | deny | requires_approval
reason: short explanation
matched_agent: agent id
matched_tool_grant: grant id
required_approval_gate: optional gate id
audit_required: true
notes:
  - evidence or missing information
```

## Tools and APIs

- `agent-skills/agents/registry/agents.yaml`
- `agent-skills/agents/registry/tool-grants.yaml`
- `docs/master-plan.md`
- Kubernetes RBAC read checks when available
- GitHub permission metadata when available

## Required Permissions

Read-only access to the agent registry, tool grant file, relevant policy docs, and optional read-only permission metadata.

## Safety Constraints

- Deny by default when the action is ambiguous.
- Never expose raw secret values.
- Never grant a permission that is not present in the registry.
- Never convert a denied action into an allowed action.
- Escalation must go through `approval-gate-manager`.

## Workflow

1. Identify the calling agent and load its registry entry.
2. Confirm the requested action maps to one of the agent capabilities.
3. Resolve the agent `toolGrant`.
4. Compare the target repo, path, namespace, API, and verb against the grant.
5. Check whether the grant requires approval.
6. Return `allow`, `deny`, or `requires_approval`.
7. Include enough evidence for audit replay.

## Example Invocation

```text
Check whether hermes-observability can read Prometheus metrics for the finance-frontend deployment in apps-prod.
```

## Success Criteria

- The answer is deterministic from registry and policy data.
- The decision contains a clear reason.
- Risky or missing context returns `requires_approval` or `deny`, not `allow`.
