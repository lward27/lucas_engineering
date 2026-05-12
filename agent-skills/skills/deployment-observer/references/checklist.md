# Deployment Observer Checklist

Use after every sandbox or live deployment.

1. Confirm Argo app sync status.
2. Confirm Argo app health status.
3. Confirm workloads are ready.
4. Check events for warnings.
5. Check recent pod restarts.
6. Run request rate, error rate, latency, CPU, and restart PromQL queries.
7. Check Tempo for representative slow or failed traces.
8. Check Grafana dashboards for panel-level warnings.
9. Confirm OTEL resource attributes include service, namespace, and version.
10. Record rollback revision or digest.
