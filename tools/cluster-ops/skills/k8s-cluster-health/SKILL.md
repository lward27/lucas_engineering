---
name: k8s-cluster-health
description: Assess the overall health of an approved Kubernetes cluster through bounded, sanitized observation. Use for cluster health checks, platform readiness, capacity and workload symptoms, or explicitly requested non-destructive remediation of a named issue. Do not use to diagnose one workload, review manifests, or perform broad cleanup.
---

# Kubernetes Cluster Health

## Inputs

Require a context. Accept an optional namespace scope, lookback duration, component scope, and an explicit remediation instruction.

## Required Reads

Read these before cluster operations:

- `../_shared/references/cluster-profile.yaml`
- `../_shared/references/safety-policy.md`
- `../_shared/references/operating-model.md`
- `../_shared/references/discovery-summary.md`
- `../_shared/references/output-contracts.md`

## Workflow

For scoped `lucas_engineering` development readiness, use the maintained `lucas-ops doctor` described in `../_shared/references/ASTRA-LUCAS-OPERATOR-INTERFACE.md`. Use the broader collector below when cluster health itself is requested. Profiles and prior snapshots are identity hints, not live health evidence.

1. Resolve the supplied context with `../_shared/scripts/context-guard.sh`; state its alias, resolved context, and scope.
2. Run `scripts/collect-health.sh --context ... --namespace ... --lookback ... --output-dir ...` for deterministic baseline evidence.
3. Inspect API reachability, versions, nodes, conditions, taints, allocatable resources, storage, warning events, pending or failing Pods, restart patterns, workload readiness, disruption budgets, and installed platform components.
4. Check Argo CD, Tekton, observability, Cilium, Hubble, ingress, cert-manager, registry, and artifact storage only when discovery proves they are present.
5. Rank findings by impact and distinguish evidence from inference. Propose the smallest remediation without executing it by default.

## Classification and Gates

Default to Class A observation. Run Class B only when the user explicitly requests a named restart, reapply, non-pruning sync, positive scale, or validated configuration fix on an approved context. Treat deleting a Job to recreate it as Class C, even when it is non-data-bearing. Do not make a change merely because the health report identifies it.

## Output

Use the diagnostic output contract. Report `healthy`, `degraded`, `critical`, or `unknown`; include checks performed, severity-ordered evidence, likely impact, recommended remediation, commands, missing visibility, and confidence. Include executed remediation and post-remediation validation only when a requested mutation ran.

## Validation and Failure

After an authorized remediation, recheck workload readiness, events, error signals, and the specific success criterion. If the API, an optional component, or telemetry is unavailable, report `unknown` for that signal. Do not substitute a cluster-wide restart or delete for missing visibility.

## Trigger Examples

- "Check whether lucas-engineering is healthy over the last 30 minutes."
- "Assess storage, nodes, and Tekton controller health on lucas-engineering-2."
- "Check lucas-engineering and restart deployment api in apps only if it is unhealthy."

## Do Not Trigger

- "Why is deployment api CrashLooping?" Use `k8s-workload-triage`.
- "Delete old completed PipelineRuns." This is a Class C cleanup request, not a health check.
