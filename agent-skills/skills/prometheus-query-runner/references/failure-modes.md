# prometheus-query-runner Failure Modes

| Failure | Handling |
| --- | --- |
| Prometheus unavailable | Return `unknown`, include endpoint and timeout. |
| Query too broad | Refuse and request namespace/app filters. |
| Empty result | Return `unknown` unless absence is explicitly expected. |
| High-cardinality response | Stop summarization, store raw result separately, ask for narrower query. |
| Permission denied | Return `deny` and route through `permission-checker`. |
