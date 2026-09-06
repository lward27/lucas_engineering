---
name: k8s-rollout-observe
description: Monitor one Kubernetes rollout and correlate its readiness, events, bounded logs, metrics, and traces against stated success criteria. Use after a deployment, sync, image update, or during a release observation window. Do not use to create deployment resources, perform an unrequested rollback, or collect a broad incident archive.
---

# Kubernetes Rollout Observe

## Inputs

Require context, namespace, workload, optional revision, observation window, expected success criteria, and an optional explicitly requested remediation instruction.

## Required Reads

Read these before cluster operations:

- `../_shared/references/cluster-profile.yaml`
- `../_shared/references/safety-policy.md`
- `../_shared/references/operating-model.md`
- `../_shared/references/observability-conventions.md`
- `../_shared/references/output-contracts.md`

## Workflow

For `lucas_engineering`, read `../_shared/references/ASTRA-LUCAS-OPERATOR-INTERFACE.md`. Prefer existing durable measurements; use managed localhost-only connections for bounded interactive reads. Keep transport failures separate from workload failures, and bind each window to its expected revision, Pod identities and timestamps.

1. State baseline, success criteria, failure criteria, observation duration, and decision points before collecting evidence.
2. Observe rollout status, ReplicaSets, Pods, readiness, restarts, events, EndpointSlices, desired versus available replicas, and GitOps status when present.
3. Query verified metrics for request rate, errors, latency, CPU, memory, throttling, restarts, unavailable replicas, pending Pods, and application health. Query bounded logs and traces only with verified labels or attributes.
4. Produce a timestamped timeline and categorize the rollout as pass, wait, investigate, or rollback recommendation.

## Classification and Gates

Default to Class A observation. A restart, positive scale, or non-pruning sync is Class B within recorded task authorization after validation. Rollback follows the exact approved recovery envelope, including baseline compatibility; otherwise explain the concrete impact and obtain the required approval. Telemetry loss alone is not proof of regression.

## Output

Use the diagnostic output contract with a timestamped rollout timeline, expected versus observed signals, recommendation, missing telemetry, and no actions executed unless authorized.

## Validation and Failure

Continue only while the rollout is progressing inside the agreed window. Pause when readiness regresses, error signals increase, or metrics are unavailable enough to judge success. Do not declare a clean pass when critical telemetry is missing.

## Trigger Examples

- "Monitor users-api for 20 minutes after this image update."
- "Watch the Argo rollout in apps-prod and correlate readiness with Loki and Mimir."
- "Observe finance-frontend until p95 latency and error rate stabilize."

## Do Not Trigger

- "Deploy users-api." Use `k8s-app-deploy`.
- "Capture all evidence for incident INC-1234." Use `k8s-incident-snapshot`.
