# change-risk-assessor

## Purpose

Classify a proposed code, GitOps, Kubernetes, secret, or deployment action by blast radius, approval requirement, audit requirement, and rollback readiness.

Use this skill before opening release PRs, merging GitOps changes, syncing Argo CD, granting permissions, changing RBAC/network policy, or touching persistent data.

## Trigger Conditions

- A task changes files under `charts/`, `cluster/`, or `agent-skills/agents/registry/`.
- A task targets `apps-prod`, `argocd`, `monitoring`, `ci`, `secrets`, or live app namespaces.
- A workflow wants to publish an image, merge GitOps changes, or sync Argo CD.
- A change touches RBAC, NetworkPolicy, PVCs, Secrets, database migrations, ingress, or TLS.

## Inputs

- `change_summary`
- `changed_paths`
- `target_environment`
- `target_namespace`
- `actor`
- `tests`
- `rollback_plan`
- `observability_plan`
- `secret_access`

## Outputs

```yaml
risk_level: low | medium | high | critical
approval_required: true
rollback_required: true
reasons: []
required_evidence:
  - tests
  - diff
  - rollback_plan
next_skill: approval-gate-manager | permission-checker | deployment-observer
```

## Tools and APIs

- Git diff summary
- `docs/master-plan.md`
- `agent-skills/agents/registry/tool-grants.yaml`
- `permission-checker`

## Risk Rules

| Risk | Examples | Default decision |
| --- | --- | --- |
| Low | Docs, diagrams, read-only skills, sandbox-only plans | No approval unless policy says otherwise |
| Medium | App source changes, non-live config, sandbox manifests | Approval usually not required before PR |
| High | Live GitOps manifests, Argo sync, registry publish, RBAC, NetworkPolicy | Approval required |
| Critical | Secret value access, PVC/database deletion, force resets, cluster-admin grants | Forbidden or human break-glass only |

## Safety Constraints

- Treat missing rollback plans as high risk for live deploys.
- Treat raw secret value access as critical.
- Treat broad Kubernetes permissions as critical unless scoped and temporary.
- Do not downgrade risk because an agent requested autonomy.

## Example Invocation

```text
Assess the risk of updating charts/finance-frontend/values.yaml to deploy sha256:example into apps-prod.
```
