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
The immutable worker image uses source `4128e28ce206a3228bb89b328fda12e6ee9ac60d`.
The wrapper uses source `772179fe7ebaf6e93436fc99113f26285a2e81f3`.
Both images passed their Python 3.11 unit/compile builds, content-digest checks,
Linux/AMD64 checks, and OCI source/revision checks. Signature, vulnerability scan,
SBOM, and cryptographic provenance verification were not performed.

Default pace: at least 65 seconds after each response/error, 250-row database
batches, and five-minute pauses every ten terminal ticker results. A 429 persists a global
cooldown of at least 15 minutes with exponential backoff and Retry-After support.
Expect roughly six days or longer. The worker stops requesting new tickers at
6GiB total database size, and the Job has a 21-day deadline.

Monitor:

```sh
kubectl --context lucas_engineering -n apps-prod get job yahoo-corporate-actions-v1-20261017-r2
kubectl --context lucas_engineering -n apps-prod logs job/yahoo-corporate-actions-v1-20261017-r2 \
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

The original Job `yahoo-corporate-actions-v1-20261017` was explicitly approved for
suspension and replacement after its first successful import and a 429 response.
Its pod was terminated, but the Job, 6,768 imported rows, 60 dividend events, one
split event, work items, and original cooldown were retained. Revision `r2`
resumes the same `yahoo-full-history-v1` run with identical configuration.
Response-based spacing plus five seconds of slack prevents a slow dispatch or
network round trip from racing the wrapper's arrival-based one-minute gate.
The database suite now includes 39 passing tests, including both timing and
cooldown-preservation regressions. Do not unsuspend the original worker alongside
the replacement.

Stopping/deleting the Job or rolling back API image pins requires the applicable
explicit operational approval. A code rollback must retain these additive tables
and source data; it must not prune persistent data.

## Revision r3 (2026-10-28)

`r2` failed on 2026-10-20 at 17:27 America/New_York (`BackoffLimitExceeded`).
Total database size had passed the 6GiB ceiling after 1,575 completed
snapshots (`market_history` about 3.97GB), so every retry stopped before the
next ticker. Separately, the `yfinance-wrapper` NetworkPolicy added on
2026-10-24 did not admit backfill pods; it now allows
`app.kubernetes.io/name: finance-market-backfill`.

With explicit approval, the ceiling was raised to 12GiB (`12884901888` bytes).
The 1,038 remaining tickers are expected to add roughly 2.7GB, which the
PostgreSQL node has room for. Because a named run refuses a changed
configuration, the stored `market_backfill.config_json` for
`yahoo-full-history-v1` was updated in place to the new `max_database_bytes`
before creating `r3`. All other options are unchanged, so completed
checkpoints are kept. `r3` uses the current production image
(`dfda532b…`, source `e29fee2`); the backfill code has not changed since `r2`.

```sh
kubectl --context lucas_engineering -n apps-prod create \
  -f ops/finance-backfill/yahoo-corporate-actions-v1-r3.yaml
kubectl --context lucas_engineering -n apps-prod logs job/yahoo-corporate-actions-v1-20261017-r3 \
  --tail=30 --since=10m
```

Do not run `r2` or the original Job alongside `r3`.
