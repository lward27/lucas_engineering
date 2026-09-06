---
name: immutable-build-release
description: Preflight and execute an explicitly authorized source-SHA-to-image-digest-to-GitOps release with remote revision, secret-safe Tekton, OCI provenance, release-pin, Argo revision, and Pod image-ID verification. Use for repeated immutable application builds and releases. Do not use to author a new pipeline, diagnose an isolated failed run, or perform a direct rollout restart.
---

# Immutable Build Release

## Inputs

Require repository, remote and protected branch, build components, target registry repositories, build context and Dockerfiles, Kubernetes context and Tekton namespace/Pipeline, GitOps repository/path, Argo Application, expected platform, rollout success criteria, and which build, merge, sync, or rollback effects are explicitly authorized.

## Required Reads

Read these before cluster or GitOps operations:

- `../_shared/references/cluster-profile.yaml`
- `../_shared/references/safety-policy.md`
- `../_shared/references/operating-model.md`
- `../_shared/references/repository-discovery.md`
- `../_shared/references/observability-conventions.md`
- `../_shared/references/output-contracts.md`

For `lucas_engineering`, read `../_shared/references/ASTRA-LUCAS-OPERATOR-INTERFACE.md` and reuse the maintained readiness and release-record tools. Existing task/program authorization persists; do not request the same approval again. Finance production approval remains a distinct gate before its GitOps merge.

## Workflow

### 1. Seal the source revision

1. Work in a clean, dedicated worktree and inspect repository instructions and release scripts.
2. Run `scripts/verify_remote_revision.sh` with the repository, remote, branch, and any requested revision. Never type, reconstruct, pad, or expand an abbreviated SHA manually.
3. Stop if the worktree is dirty, the branch moved during verification, the requested revision differs from the remote head, or the exact object is not a commit locally after fetch.
4. Carry the verified revision forward mechanically from command output or a shell variable. Re-run verification immediately before PipelineRun creation; an older preview is stale.
5. Keep source build outputs outside the clean source worktree. Record operation IDs and artifacts before waiting; resume by those identities after an interruption.

### 2. Preflight the build boundary

1. Confirm Tekton APIs, Pipeline/Task versions, registry target, ServiceAccount, workspace class/capacity, node/platform, timeouts, concurrency, and immutable builder images from repository and live read-only evidence.
2. Inspect every Task step that receives a Secret reference or credential-bearing environment variable before requesting logs or creating a run. Reject shell tracing (`set -x`, `bash -x`), environment dumps, credential-bearing URLs, command echoing, or results/params that can expose credentials. Credential setup and cleanup must execute with tracing disabled; temporary credential files must be owner-only and removed on exit.
3. Verify that the Pipeline takes a full source commit, passes that exact value to checkout and OCI revision/source labels, returns an image URL and `sha256` digest, and never restarts or patches a workload.
4. Render and run client/server dry-runs where supported. A dry-run must not create a PipelineRun, Git commit, PR, or observation.

### 3. Build only inside the authorized envelope

1. PipelineRun creation is Class B and requires explicit authorization for the named repository, revision, components, context, namespace, Pipeline, and image repositories.
2. For a multi-component release, bind every run to the same verified revision and record each PipelineRun name before waiting.
3. Require terminal success and exact immutable digest results. A failed or missing result stops the release; do not infer a digest from a convenience tag.
4. Do not fetch unfiltered logs from clone, authentication, registry-login, signing, or other credential-adjacent steps. Inspect metadata and Task definitions first. Use `tekton-run-triage` for a failed run and treat any possible logged credential as compromised.

### 4. Verify artifacts and pin the release

1. Inspect each registry artifact by digest. Require the expected OS/architecture and OCI revision/source labels matching the verified source SHA.
2. State explicitly when SBOM, vulnerability scan, signature, or cryptographically verified provenance is absent; a digest and label do not prove those controls.
3. Create a separate release change from a clean worktree. It may record only reviewed source revision and immutable digests plus required release metadata.
4. Render Helm/Kustomize, validate schemas, run server-side dry-run, and scan rendered output for mutable release images. Stop on `:latest`, a tag-only workload reference, stale source revision, or mismatched component provenance.
   Read the actual Argo value files first. The PHarness application uses `values-yfinance-production.yaml`; a default-values render alone does not validate that deployment.
5. Commit, push, merge, or sync only to the extent explicitly authorized. Never use `rollout restart`, direct Deployment image patching, force sync, or prune as a substitute for GitOps reconciliation.

### 5. Prove the live release

1. Use the `k8s-rollout-observe` workflow after reconciliation.
2. Require the exact GitOps release revision, Argo `Synced/Healthy`, desired/ready replicas, zero unexplained restarts, ready EndpointSlices, and workload image specs plus Pod `imageID` values equal to the pinned digests.
3. Verify application readiness, schema migrations, API/UI revision alignment, and component-specific acceptance criteria. Missing critical evidence is not a pass.
4. Preserve an evidence map containing verified source SHA, PipelineRuns, artifact URLs/digests/platforms/labels, release commit, Argo revision, workload generation, Pod image IDs, observation window, and residual gaps.

## Stop Conditions

Stop before further external effects on any revision mismatch, dirty worktree, moving branch, mutable image, secret-tracing risk, missing digest result, OCI label/platform mismatch, stale release preview, Argo revision mismatch, failed readiness, or newly required authorization. Fix the cause and restart from source verification; never repair provenance by editing evidence after the fact.

## Classification and Gates

Repository inspection, source verification, rendering, dry-run, registry metadata inspection, and rollout observation are Class A. PipelineRun creation, source/GitOps PR creation or merge, and non-pruning sync are Class B within the user's recorded authorization. Cancellation, deletion, prune, force sync, rollback, or persistent-data changes follow the shared safety policy's concrete authorization boundary.

## Output

Use the write-oriented output contract. Lead with the release verdict and exact verified identities. Separate observed evidence, inference, actions executed, missing proof, and rollback procedure.

## Validation and Failure

The release passes only when source, all artifacts, release pin, GitOps revision, and live Pod image identities form one exact chain. Do not call a healthy workload a successful release when provenance or required acceptance evidence is missing.
