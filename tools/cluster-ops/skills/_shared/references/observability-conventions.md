# Observability Conventions

Use discovered labels and resource attributes from the selected repository and live workload. Do not invent a Grafana data source identifier, endpoint, or credential.

## Observed Conventions

- Repository manifests commonly use `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/part-of`, `app.kubernetes.io/version`, and `app.kubernetes.io/managed-by`.
- Some current repository deployments declare OpenTelemetry resource attributes including `deployment.environment` and `service.namespace`.
- `service.name`, `service.version`, `k8s.cluster.name`, `k8s.namespace.name`, and `k8s.deployment.name` must be verified per workload before queries depend on them.
- Tekton and agent-loop label conventions are not global. Inspect the selected pipeline or workload before filtering on labels.

## Bounded Query Templates

Replace each placeholder only after confirming the label or attribute exists.

| Signal | Template | Required bounds |
| --- | --- | --- |
| Prometheus or Mimir | `sum(rate(container_cpu_usage_seconds_total{namespace="$NAMESPACE",pod=~"$WORKLOAD.*"}[$RANGE]))` | cluster/context, namespace, workload, range |
| Loki | `{namespace="$NAMESPACE"} |= "$WORKLOAD"` | cluster/context, namespace, workload, range, line limit |
| Tempo | `{ resource.service.name = "$SERVICE" && resource.k8s.namespace.name = "$NAMESPACE" }` | cluster/context, namespace, service, range, result limit |
| Hubble | `hubble observe --namespace "$NAMESPACE" --since "$RANGE"` | context, namespace, source or destination, range, flow limit |

When a local query client is unavailable, capture the missing visibility and use Kubernetes metadata and bounded logs instead. Keep rollout observations timestamped and compare error, latency, saturation, restart, and readiness changes to a stated baseline.
