# ASTRA: cert-manager upgrade to 1.20.3

The owner authorized the supported upgrade on 2026-09-05. Advance one minor at a
time: 1.14.5 → 1.15.5 → 1.16.5 → 1.17.4 → 1.18.6 → 1.19.6 → 1.20.3. Each step
requires its merged GitOps revision, three ready controller Deployments, healthy
webhook admission, and retained certificate history before the next step.

The 31 existing certificates had no explicit rotation or history settings.
[Version 1.18 changes both defaults](https://cert-manager.io/docs/releases/upgrading/upgrading-1.17-1.18/).
Keep `private-key-rotation-policy: Never` explicit on their authoritative Ingress
sources. Set `revision-history-limit: "2147483647"`, the maximum signed 32-bit
value supported by the API. This is a finite limit that preserves all current
history and practically retains the former unlimited behavior. Changing key
rotation or adopting a shorter retention policy is a separate operator decision.

For the external Forge and data-log-visual charts, use their existing ingress
annotation values through their GitOps Application definitions. PHarness has the
same annotations in its own chart. The existing Blog certificate predates
Ingress ownership, so its existing spec is now tracked alongside that Ingress.
No TLS private keys or Secret contents are stored here.

Keep CRDs enabled and retained. Preserve DNS resolvers, issuers, the Cloudflare
Secret reference, and resource limits. Do not delete certificate material,
CertificateRequests, Orders, Challenges, or finalizers to make a rollout pass.
Version 1.19 changes ACME metric labels from `path` to `action`; no matching query
was found in this GitOps repository. The reduced aggregate editor permissions
in 1.19.6/1.20.3 are retained; this program uses the normal certificate flow.

All Finance certificates renewed on 1.14.5 after credential rotation and before
the first upgrade. Their origin HTTPS endpoints returned 200 with normal
hostname and CA verification on 2026-09-05. Public Cloudflare endpoints presented
valid TLS but returned 403 to the automated probe; origin success does not prove
that an unauthenticated public client can access the application.

Authoritative per-step evidence is recorded with the PHarness ASTRA M02 artifacts
in `planning/evidence/autonomous-sdlc` of the PHarness repository. This document is
not a claim that the full autonomous SDLC program has passed acceptance.
