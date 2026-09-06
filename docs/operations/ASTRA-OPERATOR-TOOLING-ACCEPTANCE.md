# ASTRA: Operator tooling acceptance

Status: complete. Implementation, local/live validation, installation and CI passed; [PR 58](https://github.com/lward27/lucas_engineering/pull/58) merged as `a0dcded522907a2cd8f171b0fcb60f5b6bffcc62`. This is acceptance of operator tooling, not PHarness coding qualification or autonomous Finance delivery.

## Changes and boundaries

The maintained `lucas-ops` command consolidates cluster identity/readiness, the existing desktop BuildKit preflight, durable evaluation observation and guarded dispatch, and PHarness release artifact verification/pinning. It uses existing APIs and source scripts; it does not introduce a new service or controller. The environment profile names the actual kubeconfig/server, Argo source/values, private registry TLS route and credential references.

The shared Kubernetes guards now handle flags before verbs, reject ambiguous contexts and compound commands, preserve failed dry-run/ownership outcomes, and distinguish false dry-run flags from observation. Three skills use the maintained interface and honor the user's existing authorization. Named credentials stay private in memory. All other installed skills and user checkouts are preserved. The legacy broad health collector is retained; it is not presented as a new application acceptance mechanism.

## Evidence

- [25 deterministic tests](ASTRA-OPERATOR-TESTS.log): wrong-server and ambiguous-context rejection; ownership/client/server failure; private credential handling; GET-only reconnection; uncertain POST preservation with no replay; stale-source refusal; immutable results; diagnostic/qualification separation; seven-component artifact integrity; protected installation/restoration; builder mismatch and occupied-port behavior.
- All shell scripts pass syntax checks. All three SKILL.md files pass the skill creator validator using isolated `uv --with pyyaml`; no global Python package was installed.
- [First readiness attempt](ASTRA-OPERATOR-READINESS-R1.json): failed because the new tool used the desktop's direct port instead of its configured SSH route. This was a helper defect, not proof that BuildKit was unavailable. The route was corrected.
- [Corrected readiness](ASTRA-OPERATOR-READINESS-R2.json): passed cluster, namespace, pipeline, Argo binding, TLS, private authentication/permission and mTLS builder checks. Read permissions do not prove writes, successful application builds, or runtime acceptance.
- [Owned connection recovery](ASTRA-OPERATOR-CONNECTION-RECOVERY.json): terminate only the test-owned API tunnel; the next read reconnects once and returns the same deployed identity.
- [Existing evaluation recovery](ASTRA-OPERATOR-EVALUATION-RECOVERY.json): retrieve the already-failed diagnostic after its Kubernetes Job expired. No evaluation or model call was started.
- [Real AMD64 preflight](ASTRA-OPERATOR-AMD64-PREFLIGHT.json): uncached platform execution through the existing Rancher Desktop/lucas-desktop build route. No release image push or cluster mutation.
- [Release verification](ASTRA-OPERATOR-RELEASE-VERIFICATION.json): existing seven source-92 registry manifests/configs match their digests, source and Linux AMD64 identity; the local native bundle matches its SHA256. No signature, SBOM, layer audit, native internal-file test, or new deployment is claimed.

## Dispatch and recovery limitations

POST dispatch is deliberately not retried. The immutable local operation intent must be reconciled with the native API after uncertainty. This prevents local replay but does not add server-side global idempotency. Protocol calibration remains an explicit native operation. No live dispatch was needed to test this tooling; failure paths are covered deterministically. Production approval and M04's frozen qualification thresholds remain unchanged.

Release pinning delegates to PHarness's existing current-main/clean-worktree guards. It prepares a local diff; it does not merge or deploy. Only a caller's explicitly authorized release may perform those later actions.

## Installation and legacy helpers

Installed bundle `59716f40df8ba6169cacee2819c0c37afc8487926363f9305bc594f33da2e7d0` updates 23 known skill/helper files. Every installed file matches its recorded hash. The [installation receipt](ASTRA-OPERATOR-INSTALLATION.json) names the restore manifest; [installed readiness](ASTRA-OPERATOR-INSTALLED-READINESS.json) records the post-install checks.

All 91 inactive temporary ASTRA Python helpers were copied into a private archive, hash-verified, checked again for active processes and source changes, then removed from their former temporary paths. [Archive metadata](ASTRA-LEGACY-HELPER-ARCHIVE.json) records each exact file and hash. No evidence, credential file, user checkout, container image, or Kubernetes resource was deleted. Unique historical experiments are not claimed as supported CLI features.

## Current PHarness checkpoint

Deployed implementation: `92f8f1b8e98dd45d0a01e030aeb99ef9bcf95267`; PHarness main/Argo pin at observation: `4bf9f0ae73a3ed2ef25e9bca53090e0edecf32f6`. Native schema: 55; minimum compatible reader: source 92. M04 remains open. Evaluation `infeval_01a07730b1e275e096ba85c8afb04d4c` completed as a failed diagnostic with no qualification. Inspect its retained first failure before choosing another primary/control experiment. The [LEA assessment](ASTRA-LEA-RETIREMENT-ASSESSMENT.md) is read-only; no LEA retirement is authorized.

The durable [PHarness checkpoint](https://github.com/lward27/pharness/blob/main/planning/evidence/autonomous-sdlc/ASTRA-CLUSTER-OPERATOR-CHECKPOINT.md) and source-92 live evidence were committed through [PHarness PR 373](https://github.com/lward27/pharness/pull/373), merge `4206a1447744a08e3a2bf6712e0a028479a0fb23`. This is a documentation commit, not a new compiled release. The separately requested [application retirement](ASTRA-APPLICATION-RETIREMENT.md) leaves the PHarness/Finance platform and its shared dependencies in service.
