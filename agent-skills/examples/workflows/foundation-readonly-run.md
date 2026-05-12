# Foundation Read-Only Run

This workflow is the first safe end-to-end behavior for the agentic SDLC platform.

## Goal

Codex accepts a user goal, identifies the likely target, checks permissions, and performs read-only platform observation without mutating GitHub, Kubernetes, Argo CD, registry, or secrets.

## Steps

1. Run `goal-intake` on the user request.
2. Run `permission-checker` for the intended agent action.
3. If the target is a deployment, run `argocd-health-check`.
4. If metrics are needed, run `prometheus-query-runner`.
5. Summarize whether the next action is safe, requires approval, or should be denied.

## Success Criteria

- No write actions are performed.
- The selected Hermes agent exists in `agent-skills/agents/registry/agents.yaml`.
- Every action maps to a tool grant in `tool-grants.yaml`.
- Any mutation request returns an approval gate instead of executing.

## Example

```text
Check whether hermes-agent is healthy and whether any approval is needed before changing its GitOps chart.
```
