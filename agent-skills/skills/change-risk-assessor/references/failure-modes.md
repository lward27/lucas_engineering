# change-risk-assessor Failure Modes

| Failure | Handling |
| --- | --- |
| Unknown target environment | Return at least `medium` and request clarification. |
| Missing rollback for live deploy | Return `high` and require approval gate. |
| Secret values requested | Return `critical` and forbid general-agent access. |
| RBAC or NetworkPolicy broadening | Return `high` or `critical` depending on scope. |
| Data deletion | Return `critical`; require backup evidence and human approval. |
