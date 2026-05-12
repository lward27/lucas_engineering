# Read-Only Deployment Observation Prompt

```text
Use the Hermes observability agent to perform a read-only health check for <app> in namespace <namespace>.

Scope:
- Do not sync Argo CD.
- Do not patch or delete Kubernetes resources.
- Do not read Kubernetes Secret values.
- Use argocd-health-check and prometheus-query-runner.
- Report sync status, health status, recent warnings, error rate, latency, restarts, and telemetry gaps.

Return:
- pass, wait, investigate, or rollback recommendation
- evidence links or command summaries
- approval gates needed for any follow-up mutation
```
