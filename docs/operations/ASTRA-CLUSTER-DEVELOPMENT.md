# ASTRA: Development against lucas_engineering

This is the maintained interface for repeated operator work. Source lives in [`tools/cluster-ops`](../../tools/cluster-ops). It uses Python's standard library and the existing `kubectl`, Docker Buildx, SSH, Helm and PHarness release scripts. It introduces no service, Kubernetes controller, coding backend, or plugin.

## Install and validate

From a clean infrastructure checkout:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tools/cluster-ops/tests -v
PYTHONDONTWRITEBYTECODE=1 python3 tools/cluster-ops/install.py
~/.local/bin/lucas-ops --help
```

The installer creates a bundle addressed by its content hash under `~/.local/share/lucas-ops/versions`, updates `current`, and installs the command in `~/.local/bin`. Only the versioned shared helpers and three selected skills are updated. Existing unknown edits cause a conflict instead of being overwritten. The installation receipt names a backup containing the preceding files and hashes. Restore it with `python3 tools/cluster-ops/install.py --restore /absolute/path/to/installation.json`; restoration refuses subsequent edits.

## Start a work session

```sh
~/.local/bin/lucas-ops doctor --credentials --builder --output ASTRA-READINESS.json
```

The environment profile pins the intended API server, repositories, actual PHarness Argo values, registry TLS route, named credential references and existing desktop builder. Every cluster command uses the explicit kubeconfig/context; current-context is never changed. The profile is expected configuration, not authorization or cached health. Correct a changed binding in its authoritative source, then update the reference.

The default doctor is read-only. `--credentials` privately uses the three named Secrets for the already-authorized PHarness/GitHub authentication checks. Values remain in memory and never appear in arguments or receipts. The checks do not exercise source writes, run models, submit builds, or approve production.

`--builder` verifies the existing `lucas-desktop` Buildx configuration and mTLS through its SSH route. It reports platform advertisement separately from execution. The selected Rancher Desktop client and builder never fall back to another daemon or worker.

For a real uncached AMD64 execution check, use a clean PHarness worktree at current merged main:

```sh
~/.local/bin/lucas-ops builder preflight \
  --repo /absolute/path/to/clean/pharness-worktree \
  --source-revision FULL_MERGED_SOURCE_SHA \
  --output ASTRA-AMD64-PREFLIGHT.json
```

That effectful command invokes PHarness's existing platform-check build. It can establish and close its own SSH tunnel if the reviewed local port is free. An occupied port must pass the identity check; the tool never kills an existing connection. No release image is pushed.

## Resume existing work

```sh
~/.local/bin/lucas-ops evaluation status EVALUATION_ID --output-dir /absolute/evidence/path
~/.local/bin/lucas-ops evaluation watch EVALUATION_ID --output-dir /absolute/evidence/path --deadline 600
```

The durable PHarness API record is authoritative even when Kubernetes has expired its Job. Terminal results are retained once and checked for unexpected changes. Running snapshots may advance. A timeout ends observation, not the remote operation. Resume using its ID; do not submit another request to recover a lost view.

The operator client owns its localhost-only port-forward, reconnects read requests at most once after transport failure, and closes only its own process. A transport failure is missing observation, not proof of application failure. Long acceptance measurements belong in existing durable application/Job mechanisms; this CLI does not move PHarness's controller into the laptop.

## Explicit evaluation dispatch

`evaluation start` takes `--request FILE`, `--policy ID`, `--policy-revision REVISION`, `--source-revision SHA`, `--registry-hash HASH`, `--operation-id ID`, and `--output-dir DIR`. Inspect `--help` before use. The request must explicitly contain actor, reason, matching config hash, attempts and scope. The tool verifies current native identities rather than comparing unnormalized source placeholders.

An exclusive operation record is flushed before one POST. If its response is lost, the state remains `dispatch_uncertain`; inspect native records before deciding anything else. Never rename or remove that record to retry. This is protection against replay by the local operator, not a claim of server-side idempotency across different operation directories. The native API retains qualification, protocol, policy and budget enforcement. Protocol calibration is separately effectful and remains an explicit native operation.

For M04, run one diagnostic at a time, inspect the first meaningful failure, then choose the next primary/control comparison. Keep tested source fixed. Infrastructure failures, measurement defects, and model failures get distinct dispositions. A diagnostic cannot produce profile qualification.

## Verify and prepare a release

Use [the accepted source-92 release record](ASTRA-PHARNESS-RELEASE-92F8F1B.json) as a schema example. Replace the source, seven named component digests and native bundle identity from actual build evidence. The example records an existing release; it is not a request to deploy it again.

```sh
~/.local/bin/lucas-ops release verify --manifest RELEASE.json --output ASTRA-ARTIFACTS.json
~/.local/bin/lucas-ops release pin --manifest RELEASE.json --repo /absolute/clean/pharness-worktree --output ASTRA-PIN.json
```

Verification checks every registry manifest/config digest over valid TLS, Linux AMD64, OCI source/revision labels and the local native bundle checksum. It does not claim signatures, SBOMs, layer hashing, test success, or a deployment. Native bundle internal-file verification remains part of PHarness's packaging procedure.

Pinning delegates to the existing PHarness script, preserving its current-main and clean-worktree gates, and renders the actual Argo values. A failure can leave a local diff that requires inspection. The command does not commit, merge, sync or restart workloads. Complete the release's server dry-run and runtime acceptance before reporting it accepted. Finance production approval remains required before its production GitOps merge.

## Current state and evidence

Keep one current-state note per active program with source, operation IDs, installed tooling version, authorization and evidence links. Keep full receipts immutable and link them; avoid maintaining competing status narratives. Historical temporary helper scripts are retained privately as forensic input, not as current execution entry points.

- [Tooling acceptance](ASTRA-OPERATOR-TOOLING-ACCEPTANCE.md)
- [LEA assessment](ASTRA-LEA-RETIREMENT-ASSESSMENT.md)

The PR check runs deterministic failure/recovery tests without cluster credentials. Live read-only checks and the explicit AMD64 build test are recorded separately.
