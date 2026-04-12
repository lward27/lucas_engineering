# Scraper Manager Queue Cutover

## Deploy Order

1. `postgresql` chart sync (creates `finance_app` DB + `finance_app_user` and ensures Timescale extension).
2. `finance-app-database-service` sync (PG env vars + startup retry).
3. `rabbitmq` sync.
4. `scraper-manager` sync (scheduler + worker deployments).

## Shadow Mode

Both scheduler and workers are deployed with `SHADOW_MODE=true`.

- Scheduler still enqueues stale ticker tasks.
- Workers fetch/transform but do not write to DB.
- Use logs, run-tracking endpoints, and queue metrics to validate behavior for 3 market days.

## Write Cutover

Set worker `SHADOW_MODE=false` and restart worker deployments:

```bash
kubectl -n apps-prod set env deployment/scraper-manager-worker SHADOW_MODE=false
kubectl -n apps-prod rollout status deployment/scraper-manager-worker
```

## Rollback

If needed, set workers back to `SHADOW_MODE=true` and restart `scraper-manager-worker`.
