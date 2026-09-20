# Network Policies

Network policies in this directory are phase-1 scaffolding for agent runtime isolation.

Current intent:

- default-deny only the new `agent-runtime` namespace
- allow DNS from `agent-runtime`

Do not add default-deny policies for `apps`, `apps-prod`, `monitoring`, `ci`, or `argocd` without testing in `sandbox` first.
