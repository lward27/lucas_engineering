# OpenClaw Observability Architecture

## Actual Architecture (discovered from cluster)

OpenClaw's operator deploys a **3-container pod**:
1. `openclaw` — main app, sends OTLP to localhost:4318
2. `gateway-proxy` — nginx reverse proxy on :18790 → :18789
3. `otel-collector` — sidecar, receives OTLP on :4318, exports Prometheus metrics on :9090

```
OpenClaw Pod (apps-prod)
    ┌─────────────────────────────────────────────────────┐
    │ openclaw ──OTLP──► otel-collector ──► :9090/metrics │
    │                    (sidecar)                        │
    └─────────────────────────────────────────────────────┘
                              │
              Prometheus scrapes :9090
                              │
                    ┌─────────▼──────────┐
                    │ Prometheus server   │──remote write──► Mimir
                    └────────────────────┘
                              
    Pod stdout (plain text) ──► Promtail ──► Loki
```

## What's Configured

### Metrics (sidecar OTel → Prometheus → Mimir)
- **Sidecar**: Operator auto-deploys OTel Collector sidecar that converts OTLP → Prometheus
- **Service**: `openclaw.apps-prod.svc.cluster.local:9090` (port name: `metrics`)
- **Scrape**: Static target in `charts/prometheus/values.yaml`
- **Grafana Dashboard**: CRD-native `grafanaDashboard.enabled: true` — operator creates
  ConfigMap with proper metrics the sidecar actually exposes

### Logs (stdout → Promtail → Loki)
- **Format**: Plain text (NOT JSON despite CRD setting `format: json`)
- **Example**: `2026-04-02T19:41:14.684+00:00 [ws] ⇄ res ✓ sessions.list 73ms conn=14ec...`
- **Promtail**: Regex pipeline extracts `component` and `method` labels
- **Query**: `{app="openclaw"}` in Loki / Grafana Explore

### Traces — NOT YET AVAILABLE
- The sidecar OTel collector only has a metrics pipeline (no traces exporter)
- The CRD has no `observability.tracing` field
- Would require operator update to add traces forwarding to the sidecar config
- When available, sidecar should forward traces to `opentelemetry-collector.monitoring.svc:4317`

### Network Policy
- Egress to monitoring namespace on :4317/:4318 (for future tracing support)

### Grafana
- Sidecar dashboard discovery enabled (`grafana_dashboard: "1"`, `searchNamespace: ALL`)
- Operator-generated dashboard will appear in "OpenClaw" folder

## Key Learnings

| Assumption | Reality |
|---|---|
| OpenClaw sends OTLP externally | Sends to localhost:4318 sidecar only |
| Logs are JSON | Logs are plain text with key=value pairs |
| Can configure tracing via env vars | OTEL env vars override sidecar routing, breaking metrics |
| Need custom Grafana dashboard | CRD has `grafanaDashboard` feature built in |
| Need ServiceMonitor | No Prometheus Operator; use static scrape config |
