# lucas_engineering
ArgoCD Kubernetes

For development against the existing cluster, start with [the maintained operator tools](docs/operations/ASTRA-CLUSTER-DEVELOPMENT.md). They provide readiness checks, resumable PHarness observation, immutable release verification, and versioned Kubernetes skills.

[LEA retirement considerations](docs/operations/ASTRA-LEA-RETIREMENT-ASSESSMENT.md) describe the separate Talos cluster and the decisions needed before reclaiming it.

[Application retirement record](docs/operations/ASTRA-APPLICATION-RETIREMENT.md) documents the 2026-09-06 removal of Odoo, Clawspace/OpenClaw, Epheros, Uptime Kuma and Code Server. Their initially retained storage and databases were subsequently [purged with owner authorization](docs/operations/ASTRA-RETIRED-DATA-PURGE.md).
