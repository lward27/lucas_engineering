# Yahoo corporate-action backfill

This is an explicitly operated, one-time Job, not an automatically reconciled
Argo resource. Merge the service image pins, verify both API rollouts and their
new routes, and only then create the reviewed Job on `lucas_engineering`:

```sh
kubectl --context lucas_engineering -n apps-prod create --dry-run=server \
  -f ops/finance-backfill/yahoo-corporate-actions-v1.yaml
kubectl --context lucas_engineering -n apps-prod create \
  -f ops/finance-backfill/yahoo-corporate-actions-v1.yaml
```

Production rollout and the full-catalog import require the finance-production
approval gate. This run was approved for the complete existing ticker catalog.
The immutable worker image uses source `d13935465ca01feadd0864bc1caee12e33fc4c7e`.
The wrapper uses source `772179fe7ebaf6e93436fc99113f26285a2e81f3`.
Both images passed their Python 3.11 unit/compile builds, content-digest checks,
Linux/AMD64 checks, and OCI source/revision checks. Signature, vulnerability scan,
SBOM, and cryptographic provenance verification were not performed.

Default pace: one full-history request per minute, 250-row database batches, and
five-minute pauses every ten terminal ticker results. A 429 persists a global
cooldown of at least 15 minutes with exponential backoff and Retry-After support.
Expect roughly six days or longer. The worker stops requesting new tickers at
6GiB total database size, and the Job has a 21-day deadline.

Monitor:

```sh
kubectl --context lucas_engineering -n apps-prod get job yahoo-corporate-actions-v1-20261017
kubectl --context lucas_engineering -n apps-prod logs job/yahoo-corporate-actions-v1-20261017 \
  --tail=30 --since=10m
```

The database API exposes read-only progress at
`/market-data/backfills/yahoo-full-history-v1` and recorded gaps at the `/items`
subroute. Data reads use `/market-data/tickers/{ticker_id}/history`.
Unavailable/delisted symbols are gaps, not fabricated success.

The source snapshot preserves dividends, splits, capital-gain distributions,
adjusted close, and explicit Yahoo split-adjusted basis. It is **not yet a
simulation-qualified release**. Legacy `price_history` is not altered.

Completed records, partial snapshot batches, and cooldowns live in PostgreSQL.
If a failed Job needs resumption, create a separately reviewed Job with a fresh
Kubernetes name but the same `--name` and configuration. Do not launch a second
worker to bypass a cooldown. Do not delete checkpoints or change old snapshots.

Stopping/deleting the Job or rolling back API image pins requires the applicable
explicit operational approval. A code rollback must retain these additive tables
and source data; it must not prune persistent data.
