# deployment-observer Failure Modes

| Failure | Handling |
| --- | --- |
| Argo is OutOfSync | Return `investigate`; do not sync automatically. |
| App is Progressing | Return `wait` until timeout, then `investigate`. |
| App is Degraded | Return `investigate` or `rollback`. |
| Metrics missing | Return `unknown` or `warn`; flag telemetry gap. |
| Critical alert firing | Return `rollback` or `investigate` depending on persistence. |
| Rollback revision unknown | Block final success and request rollback metadata. |
