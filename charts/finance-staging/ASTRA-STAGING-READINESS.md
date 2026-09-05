# ASTRA Finance staging readiness

Updated 2026-09-05 from GitOps main
`137262f4377c5f1d19379f73e83249d66d09a0fd` for PHarness M02.
Both staging applications are Synced/Healthy and run their exact pinned images.
All 13 required/denied network connections passed after the public-ingress correction.

## Scope and ownership

Two Argo applications own the internal `apps-staging` deployments:
`yfinance-staging` and `finance-frontend-staging`. Each overlays its existing
application manifests and owns a separate image digest in its Kustomization.
There is no staging Ingress. The root application owns the namespace labels.

The production frontend now uses Kustomize to pin its observed running digest,
`sha256:248437be58bdeed738d614d13dd2c09232c18119ea0f10309e2a14ffed6d3f3d`,
and mount a non-secret runtime configuration file. The image is unchanged.
Its original source provenance has not been established; do not invent a source SHA.
Yfinance staging starts from observed production digest
`sha256:f1cfc06fcac62d7c37a4d7dc87237e2abe02df0d9c3824a7521c5359058879c1`.
Production yfinance remains in its existing Argo sync mode until PHarness M09.

## Runtime configuration contract for M11

`/runtime-config.json` contains `schemaVersion: 1`, an `environment` of
`production` or `staging`, and `services.database`, `services.yfinance`, and
`services.scraper`. A service value is an explicit HTTP(S) base URL, a same-origin
absolute path, or null when deliberately unavailable. Null never falls back to
localhost or production. No credentials belong in this file.

Production database and yfinance URLs match the existing frontend configuration.
The existing production build has no scraper URL, so that service is explicitly
unavailable. Staging binds only yfinance through `/api/yfinance`; database and
scraper access are unavailable until independently provisioned and authorized.
The existing frontend image does not consume this file. M11 must implement and
test loading/validation before application initialization; serving this file alone
does not satisfy that milestone.

## Isolation and access

The frontend browser policy permits connections only to its staging origin.
This blocks compiled production URLs in the current image. Nginx proxies only
GET/HEAD requests under `/api/yfinance/` to staging yfinance and returns 503 for
unbound `/api/` routes. The frontend Pod can reach only cluster DNS and staging
yfinance. Yfinance can reach DNS, the existing telemetry collector, and public
HTTPS. Private cluster and LAN address ranges are excluded from that HTTPS rule.
A live probe found that the general HTTPS rule still reached all three Finance
production hostnames through Cloudflare. The yfinance policy now also excludes
all 15 [published Cloudflare IPv4 ranges](https://www.cloudflare.com/ips-v4),
verified on 2026-09-05. Production names currently resolve inside those ranges.
There is no IPv6 egress allowance. Yahoo and the collector must remain reachable.
Revalidate this finite hosting boundary if production ingress/DNS or upstream
providers change. This deliberately limits staging access to other Cloudflare
services too; it is not a general hostname firewall or protection against an
arbitrary external relay.
Neither staging Pod mounts a service-account token.

Network policies select only these new staging applications. Post-deployment
application-labelled probes denied all ten tested private/public production
connections and allowed the three necessary staging-backend, Yahoo and telemetry
connections. They sent no production mutation requests. Revalidate these paths
after a policy, DNS, ingress or service-binding change.

## Pre-merge review

- Production and both staging Kustomizations render successfully.
- The root Helm chart renders and passes lint.
- The production frontend manifest passes server-side dry-run in `apps-prod`.
- Both staging manifests pass client-side API validation. The yfinance overlay
  also passes server-side dry-run in the existing `apps-staging` namespace.
- The exact frontend image was pulled using Rancher Desktop with
  `--platform linux/amd64`; `nginx -t` passes with this staging configuration.
- Existing production frontend security settings produce a restricted-policy
  warning; its namespace enforces baseline. This change does not claim hardened
  container execution.

## Observed platform checks

The original yfinance image was absent from the registry. Its exact descriptor
graph was recovered from the production node cache with every content hash
verified and restored without rebuilding or restarting production. Staging
pulled digest `f1cfc06f...` and became Ready at 2026-09-05 10:11 UTC.

Staging HTTP checks returned 200 for the document, runtime configuration, backend
health, and a five-day SPY history query. Unbound database requests returned 503
and POST to the backend proxy returned 403. These port-forward checks prove HTTP
behavior, not policy enforcement. Separate application-labelled init-container
probes confirmed the frontend reaches only its staging backend and blocks the
observed private/public production targets. The backend public path finding is
the reason for this policy correction. After GitOps merge `516c7fcb...`, the
backend denied all five production paths while preserving Yahoo and collector
access. A five-day MSFT history request still returned 200. Probe Pods never
become Ready endpoints. Fresh staging yfinance request metrics, Pod/container-
scoped logs and Tempo traces were also observed; frontend Nginx logs are present.
Frontend application traces and request metrics are not established.

The PHarness evidence directory owns the exact before/after results, image
identities, timestamps, and remaining program gates.

## Deployment and recovery

Merge only the reviewed GitOps revision and observe root and child Argo applications.
Record the exact synchronized revision, desired digest, and running Pod image ID.
Check `/runtime-config.json`, the frontend response policy, staging yfinance health,
GET/HEAD proxy behavior, denied writes, and unavailable service behavior. Observe
fresh staging-scoped LGTM signals. Frontend application behavior remains M11 pending.

If staging fails, retain evidence and repair this overlay; do not redirect it to
production. Keep production digest/configuration recovery as a scoped GitOps revert.
Removing the namespace, applications, or stored history requires separate destructive
approval; recovery does not require those deletions.
