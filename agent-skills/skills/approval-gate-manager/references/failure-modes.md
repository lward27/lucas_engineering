# approval-gate-manager Failure Modes

| Failure | Handling |
| --- | --- |
| Missing rollback plan for live deploy | Block the approval request until rollback is defined. |
| Vague target such as "the app" | Ask for exact app, namespace, and revision. |
| Multiple risky actions in one request | Split into separate gates. |
| Secret value requested by general agent | Mark forbidden. |
| Approval expired | Require fresh approval. |
