# Agentic SDLC Permissions Model

Date: 2026-05-10

This document is the implementation-facing permissions model for the Hermes-only phase 1 platform.

## Source Files

| Purpose | File |
| --- | --- |
| Agent registry | `agent-skills/agents/registry/agents.yaml` |
| Tool grants | `agent-skills/agents/registry/tool-grants.yaml` |
| Skill catalog | `agent-skills/skills/catalog.yaml` |
| Registry validator | `agent-skills/agents/registry/scripts/validate-agent-registry.rb` |
| Foundation validator | `agent-skills/scripts/validate-foundation.rb` |
| Desktop kubeconfig helper | `agent-skills/scripts/generate-desktop-hermes-kubeconfig.rb` |
| Read-only Kubernetes RBAC | `cluster/rbac/hermes-readonly-observer.yaml` |
| Network policy scaffolding | `cluster/network-policies/` |

## Phase 1 Rule

Hermes is the only active worker runtime and it runs on the desktop host. Custom harnesses are schema-level future support only. The platform starts with read-only observation, planning, review, and gated GitOps proposal work.

Kubernetes RBAC is granted to `system:serviceaccount:hermes-agent:hermes-agent`. Desktop Hermes can use that identity only when supplied a kubeconfig generated from that service account token.

## Default Policy

| Action | Default |
| --- | --- |
| Read docs, diagrams, charts, and agent-skills | Allowed for registered Hermes agents |
| Run read-only Argo/Kubernetes/observability checks | Allowed for `hermes-observability` |
| Create planning docs or examples | Allowed for planning agents |
| Modify charts or cluster manifests | Approval required |
| Create release PRs | Approval required |
| Sync Argo CD | Approval required and not yet implemented |
| Publish images | Approval required and not yet implemented |
| Read Kubernetes Secret values | Forbidden for general agents |
| Delete PVCs, databases, or live resources | Forbidden without human break-glass |

## Active Tool Grants

| Grant | Actor | Permission shape |
| --- | --- | --- |
| `hermes-readonly-planning` | `hermes-planning` | Repo/docs/agent-skills read, docs/example writes |
| `hermes-readonly-review` | `hermes-reviewer` | Repo and diff read only |
| `hermes-readonly-observability` | `hermes-observability` | Read-only Kubernetes, Argo, Grafana, Prometheus, Mimir, and Tempo |
| `hermes-gitops-proposer` | `hermes-gitops-release` | Planned PR proposer; approval required |

## Approval Gates

`approval-gate-manager` must be used before:

- GitOps manifest changes for live app paths
- Argo CD sync
- registry publication
- RBAC or NetworkPolicy broadening
- secret reference grants
- rollback outside sandbox
- destructive operations

## Validation

Run:

```bash
ruby agent-skills/scripts/validate-foundation.rb
```

The validator checks:

- registry consistency
- skill catalog consistency
- YAML/JSON parse health
- no retired runtime references

## Next Permission Milestones

1. Add sandbox-only build executor RBAC.
2. Add GitOps proposer token handling through secret references.
3. Add Argo read-only token wiring for `argocd-health-check`.
4. Add explicit approval record storage under `agent-skills/run-logs/`.
5. Add live sync and rollback permissions only after sandbox evidence exists.
