# Agent Registry

This folder holds the Git-backed registry Codex uses to discover approved Hermes agents, their allowed skills, tool grants, model policy, service account, and audit sink.

Phase 1 is Hermes-only. Custom harness entries belong in `futureRuntimes` until an actual harness exists with scoped RBAC, network policy, and audit logging.

Validate with:

```bash
ruby agent-skills/agents/registry/scripts/validate-agent-registry.rb
```
