# Agent Skills

This directory is the home for Codex/Hermes operational playbooks, agent registry metadata, and reusable prompts for the agentic homelab SDLC platform.

Phase 1 uses desktop-hosted Hermes as the only worker runtime. The Kubernetes Hermes front door and service-account support have been retired; custom harness support may be added later through the registry schema.

```text
agent-skills/
  skills/
  agents/
    registry/
  examples/
    prompts/
    workflows/
```

Start with the read-only foundation workflow in `examples/workflows/foundation-readonly-run.md`.

Validation:

```bash
ruby agent-skills/agents/registry/scripts/validate-agent-registry.rb
ruby agent-skills/scripts/validate-skills.rb
ruby agent-skills/scripts/validate-foundation.rb
ruby agent-skills/scripts/mvp-readiness.rb
```
