# ASTRA Finance staging readiness

Prepared 2026-09-04 against GitOps main
`fa27225c4c33b710ce24708e17fd39ac05ab6aeb` for PHarness M02.
Deployment acceptance remains pending live reconciliation and isolation checks.

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
HTTPS; private cluster and LAN address ranges are excluded from that HTTPS rule.
Neither staging Pod mounts a service-account token.

Network policies select only these new staging applications. Their actual
enforcement must be verified after deployment, including denied access to a
production mutation path. Do not substitute a policy manifest for that test.

## Pre-merge review

- Production and both staging Kustomizations render successfully.
- The root Helm chart renders and passes lint.
- The production frontend manifest passes server-side dry-run in `apps-prod`.
- Both staging manifests pass client-side API validation. Server-side validation
  remains due once the new namespace exists.
- The exact frontend image was pulled using Rancher Desktop with
  `--platform linux/amd64`; `nginx -t` passes with this staging configuration.
- Existing production frontend security settings produce a restricted-policy
  warning; its namespace enforces baseline. This change does not claim hardened
  container execution.

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
