# OpenClaw Observability Architecture

## Data Flow

```
OpenClaw Pod (apps-prod)
    │
    ├── OTLP gRPC (:4317) ──► OTel Collector (monitoring) ──► Tempo (traces)
    │                                                      ──► Mimir (metrics via OTLP)
    │                                                      ──► Loki (logs via OTLP)
    │
    ├── /metrics ──► Prometheus (scrape) ──► Mimir (remote write)
    │
    └── stdout (JSON) ──► Promtail (daemonset) ──► Loki
                              │
                              └── JSON parsing extracts: level, agent, tool_name,
                                  event_type, model, trace_id
```

## What Was Configured

### 1. Tracing (OpenClaw → OTel Collector → Tempo)
- **File**: `charts/openclaw/templates/openclawinstance.yaml`
- OTEL env vars injected: `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_TRACES_EXPORTER`, `OTEL_RESOURCE_ATTRIBUTES`, `OTEL_EXPORTER_OTLP_PROTOCOL`
- Sends traces via gRPC to `opentelemetry-collector.monitoring.svc.cluster.local:4317`
- OTel Collector already routes traces → Tempo
- Controlled by `values.yaml` → `openclaw.observability.tracing.enabled`

### 2. Metrics (OpenClaw → Prometheus → Mimir)
- **File**: `charts/prometheus/values.yaml`
- Added `openclaw` scrape job using `kubernetes_sd_configs` targeting `apps-prod` namespace
- Matches pods with label `app.kubernetes.io/name: openclaw`
- Scraped at default interval, metrics forwarded to Mimir via existing `remoteWrite`
- OTEL metrics also sent via HTTP to OTel Collector → Mimir

### 3. Logs (OpenClaw → Promtail → Loki)
- **File**: `charts/promtail/values.yaml`
- Added dedicated `openclaw` scrape job with JSON pipeline stages
- Extracts labels: `level`, `agent`, `tool_name`, `event_type`, `model`
- `trace_id` sent as structured metadata for Tempo correlation
- Query example: `{app="openclaw"} | json | tool_name="bash"`

### 4. Network Policy
- **File**: `charts/openclaw/templates/networkpolicy.yaml`
- Added egress rule allowing TCP 4317 + 4318 to `monitoring` namespace
- Required for OTLP export to the OTel Collector

### 5. Grafana Dashboard
- **File**: `charts/openclaw/templates/grafana-dashboard-configmap.yaml`
- ConfigMap with label `grafana_dashboard: "1"` for sidecar auto-discovery
- Dashboard UID: `openclaw-overview`
- Panels:
  - **RED Metrics**: LLM API call rate, error rate, latency (p50/p95/p99)
  - **Tool Usage**: Pie chart of tool invocations from Loki
  - **Agent Activity**: Stacked bar chart of events per agent
  - **Token Usage**: Prompt vs completion token burn rate
  - **Log Stream**: Recent logs with trace ID links to Tempo
  - **Resource Usage**: Container CPU + memory

### 6. Grafana Datasource Cross-Links
- **File**: `charts/grafana/values.yaml`
- Enabled sidecar dashboard discovery (`searchNamespace: ALL`)
- Loki → Tempo: `derivedFields` extracts `trace_id` from JSON logs, links to Tempo
- Tempo → Loki: `tracesToLogs` config for jumping from traces back to correlated logs
- Tempo → Mimir: `serviceMap` for service graph visualization

## Adjustments from Original Plan

| Original Plan | What We Did Instead | Why |
|---|---|---|
| Send OTLP directly to Tempo | Route through OTel Collector | Collector already deployed, handles fan-out to Tempo + Mimir + Loki |
| ServiceMonitor CRD | Static `extraScrapeConfigs` | No Prometheus Operator installed (using community chart) |
| Grafana sidecar assumed enabled | Enabled sidecar in `grafana/values.yaml` | Wasn't configured yet |
| Node.js auto-instrumentation init container | Env vars only | OpenClaw likely has native OTel support; env vars are the standard approach. If needed, init container can be added later |

## Verification After Sync

1. Check traces appear in Grafana → Explore → Tempo → `service.name = openclaw`
2. Check logs in Grafana → Explore → Loki → `{app="openclaw"} | json`
3. Check Prometheus target: `prometheus.lucas.engineering/targets` → look for `openclaw` job
4. Check dashboard: Grafana → Dashboards → OpenClaw folder → "OpenClaw Overview"
5. Verify NetworkPolicy allows OTLP: `kubectl exec -n apps-prod openclaw-0 -- curl -s http://opentelemetry-collector.monitoring.svc.cluster.local:4318/v1/traces`
