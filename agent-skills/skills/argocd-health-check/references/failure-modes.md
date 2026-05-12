# argocd-health-check Failure Modes

| Failure | Handling |
| --- | --- |
| App missing | Return `investigate`; verify root app registration. |
| OutOfSync | Return `investigate`; do not sync without approval. |
| Progressing too long | Return `wait` with timeout or `investigate` after timeout. |
| Degraded resources | Return `investigate` or `rollback` depending on severity. |
| Image digest mismatch | Return `investigate`; check GitOps manifest and rollout. |
| Kubernetes API denied | Return `unknown`; include permission failure. |
