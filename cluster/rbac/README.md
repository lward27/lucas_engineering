# RBAC

Phase 1 grants Hermes read-only observation permissions only.

The `hermes-readonly-observer` role allows `get`, `list`, and `watch` for workload health, Argo CD applications, Tekton runs, ingress, network policy, and pod logs. It intentionally does not grant Kubernetes Secret reads or mutation verbs.

Any future build, GitOps, sync, rollback, or secret access role must be added separately and routed through `approval-gate-manager`.
