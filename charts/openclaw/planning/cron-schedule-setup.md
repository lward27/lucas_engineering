# OpenClaw Cron Schedule Setup

Run these commands from within the openclaw pod or via the Control UI.

```bash
# Connect to the pod
kubectl exec -it openclaw-0 -n apps-prod -c openclaw -- sh
```

---

## Sentinel - The Guardian

### Cluster Health Scan (every 8 hours)
```bash
openclaw cron add \
  --name "Cluster health scan" \
  --agent sentinel \
  --every 8h \
  --session isolated \
  --message "Run a full cluster health scan. Check all pods across namespaces for non-Running states, high restart counts, and OOMKills. Check node resource usage (CPU, memory). Check ArgoCD app sync/health status. Report in your standard status format with severity levels."
```

### Certificate Expiry Check (daily 6 AM EST)
```bash
openclaw cron add \
  --name "Certificate expiry check" \
  --agent sentinel \
  --cron "0 6 * * *" \
  --tz "America/New_York" \
  --session isolated \
  --message "Check all TLS certificates across the cluster. List each cert with its namespace, Ready status, and days until expiry. Flag any cert expiring within 14 days as WARN, within 7 days as CRIT."
```

### Resource Usage Report (daily 8 AM EST)
```bash
openclaw cron add \
  --name "Resource usage report" \
  --agent sentinel \
  --cron "0 8 * * *" \
  --tz "America/New_York" \
  --session isolated \
  --message "Generate a resource usage report. Check node CPU and memory utilization. Check PVC usage for all persistent volumes. Identify pods with highest resource consumption. Flag anything above 80% as WARN, above 90% as CRIT. Compare with previous reports if available."
```

### Weekly Security Audit (Monday 7 AM EST)
```bash
openclaw cron add \
  --name "Weekly security audit" \
  --agent sentinel \
  --cron "0 7 * * 1" \
  --tz "America/New_York" \
  --session isolated \
  --message "Perform a weekly security audit. Check: 1) All namespaces have Pod Security Standard labels. 2) NetworkPolicies exist for all application namespaces. 3) No pods running as root unnecessarily. 4) No images using :latest tags from public registries. 5) ArgoCD apps are synced with no drift. 6) No stale secrets or unused service accounts. Report findings with severity levels."
```

---

## Herald - The Briefer

### Morning Brief (daily 7:30 AM EST)
```bash
openclaw cron add \
  --name "Morning brief" \
  --agent herald \
  --cron "30 7 * * *" \
  --tz "America/New_York" \
  --session isolated \
  --message "Prepare the morning brief for Lucas. Include: 1) Cluster status one-liner (healthy/issues). 2) Any overnight pod restarts or errors. 3) ArgoCD sync status. 4) Weather in Concord, NC today. 5) Any pending action items from recent agent activity. Keep it scannable — sections with bullet points."
```

### Weekly Recap (Friday 5 PM EST)
```bash
openclaw cron add \
  --name "Weekly recap" \
  --agent herald \
  --cron "0 17 * * 5" \
  --tz "America/New_York" \
  --session isolated \
  --message "Prepare the weekly recap. Review the past week: 1) What got deployed or changed (check ArgoCD history, recent git commits). 2) Any incidents or issues that came up. 3) Cluster health trends over the week. 4) Highlights and wins. 5) Anything pending for next week. Format as a crisp newsletter-style summary."
```

---

## Ticker - The Quant

### Post-Market Scraper Check (daily 7 PM EST)
```bash
openclaw cron add \
  --name "Post-market scraper check" \
  --agent ticker \
  --cron "0 19 * * 1-5" \
  --tz "America/New_York" \
  --session isolated \
  --message "Run post-market data pipeline check. 1) Check if today's scraper-manager CronJob ran successfully (kubectl get jobs). 2) Query the database service at finance-db.lucas.engineering for /tickers/update-status to see if any tickers are behind. 3) Spot-check 3 random tickers to confirm today's price data exists. 4) Report total tickers tracked, data freshness, and any gaps found."
```

### Weekly Data Quality Report (Sunday 12 PM EST)
```bash
openclaw cron add \
  --name "Weekly data quality report" \
  --agent ticker \
  --cron "0 12 * * 0" \
  --tz "America/New_York" \
  --session isolated \
  --message "Generate a weekly data quality report. 1) Total tickers tracked and total rows in price_history. 2) Identify any tickers with gaps in their history (missing trading days). 3) Check for any tickers that haven't been updated in over 7 days. 4) Scraper success rate over the past week (successful vs failed jobs). 5) Storage usage trend for the PostgreSQL PVC. Present with exact numbers."
```

---

## Verification

After adding all jobs, verify they're registered:

```bash
openclaw cron list
```

Expected: 8 jobs across 3 agents.

To check a job's next run time:
```bash
openclaw cron info <job-id>
```

To manually trigger a job for testing:
```bash
openclaw cron run <job-id>
```
