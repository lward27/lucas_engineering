# permission-checker Failure Modes

| Failure | Handling |
| --- | --- |
| Missing agent entry | Deny and request registry update. |
| Unknown tool grant | Deny and flag registry drift. |
| Ambiguous target namespace | Require approval or clarification. |
| Requested secret value access | Deny unless human break-glass path is active. |
| GitOps write to live chart | Require approval. |
| Direct cluster mutation | Deny unless emergency policy explicitly allows it. |
