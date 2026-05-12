# approval-gate-manager API Contracts

## Input Contract

```yaml
action: argocd-sync
actor: hermes-gitops-release
target: finance-frontend
environment: apps-prod
risk_level: high
evidence:
  gitops_diff: link-or-path
  image_digest: sha256:example
  tests: passed
  health_check: pending
rollback_plan: previous digest sha256:previous
```

## Output Contract

```yaml
gate_id: argocd-sync-finance-frontend-apps-prod
decision: approval_required
approval_prompt: Approve Argo CD sync for finance-frontend in apps-prod to sha256:example?
required_evidence:
  - gitops_diff
  - image_digest
  - tests
  - rollback_plan
audit_required: true
expires_after: 30m
```
