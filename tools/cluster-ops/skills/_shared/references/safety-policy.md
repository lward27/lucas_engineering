# Kubernetes Operations Safety Policy

Read this policy with `cluster-profile.yaml` and `operating-model.md` before any cluster operation.

## Context and Secrets

- Require an explicit context for every operation and an explicit namespace for namespaced work.
- Resolve only contexts listed in the profile. Treat other contexts as read-only and do not mutate them.
- Pass `--context` to `kubectl` and use the profile-selected kubeconfig. Never change the current context.
- Never display credential values or dump Secrets, kubeconfigs, workload environments, or authorization headers. When an authorized operation needs a named credential, use a private client that reads only that Secret/key into memory and sends it only to the configured service. Do not put values in command arguments, evidence, temporary files, or the conversation. Session authorization persists; do not ask again for access already granted.
- Bound events, logs, metrics, traces, and flows by target, time window, and result count. Prefer metadata and read APIs. A bounded `kubectl exec` may be used within the user's authorized task when needed; inspect its command and data impact first. Diagnostic access is not authority to alter a workload or database.

## Operation Classes

### Class A: observation

Use for bounded reads, status, describe except Secrets, logs, events, top, rollout status, diff, dry-run, GitOps status, Tekton status, telemetry queries, Cilium status, and Hubble observation. Identify context, namespace, target, and time window before proceeding. An operation named "preflight" may send model requests or create records; classify its actual effects, not its label.

### Class B: non-destructive mutation

Use for validated apply/create/patch, Helm upgrade or install, non-pruning GitOps sync, a requested PipelineRun, image updates, resource adjustments, labels, annotations, namespace creation, approved NetworkPolicies, and scaling above zero. Only run Class B when the request explicitly authorizes the named change on an approved context.

Before Class B: identify target, validate locally, use client and server dry-run where available, make the concrete diff reviewable, and check GitOps ownership. Proceed when that operation is already covered by the user's task or recorded program authorization. A profile, classifier verdict, or passed dry-run does not supply authorization. Prefer the authoritative repository when GitOps owns the resource.

### Class C: destructive or high-risk mutation

Use for delete, prune, uninstall, forced replacement, namespace/PVC/PV/CRD removal, finalizer removal, scale to zero, drain, rollback with potential data impact, deletion or cancellation of Tekton runs, or any action likely to cause data loss or broad interruption.

Before Class C: require the user to authorize the destructive outcome, name every affected resource, explain service and persistent-data impact, and make exact commands reviewable. Obtain final confirmation when that concrete action is not already explicitly authorized. A recorded, bounded recovery policy can authorize its exact rollback; do not expand it or reinterpret general permission as production approval. Never use broad wildcard deletes or unallowlisted prune operations. Considering retirement is not authorization to stop or delete a cluster.

## Intent Rules

"Why is this failing?" calls for diagnosis. Requests to implement, fix, or clean up authorize the necessary routine changes within their established scope. Preserve earlier authorization and constraints; ask only when an unresolved decision materially changes scope, risk, or production authority. An approval gate explicitly required by the program remains in force.

## GitOps and Validation

Inspect Argo CD or Flux ownership before direct mutation. Change source manifests when they are authoritative; describe any direct override as temporary. Separate observed evidence, inference, proposed remediation, executed remediation, and post-change validation in every report.
