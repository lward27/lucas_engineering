# PromQL Library

## Request Rate

```promql
sum(rate(http_requests_total{namespace="$namespace", app="$app"}[5m]))
```

## 5xx Error Rate

```promql
sum(rate(http_requests_total{namespace="$namespace", app="$app", status=~"5.."}[5m]))
/
sum(rate(http_requests_total{namespace="$namespace", app="$app"}[5m]))
```

## p95 Latency

```promql
histogram_quantile(0.95, sum by (le, route) (rate(http_request_duration_seconds_bucket{namespace="$namespace", app="$app"}[5m])))
```

## Pod Restarts

```promql
sum by (pod) (kube_pod_container_status_restarts_total{namespace="$namespace", pod=~"$app.*"})
```

## CPU Usage

```promql
sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="$namespace", pod=~"$app.*"}[5m]))
```
