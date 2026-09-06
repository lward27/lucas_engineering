# Lucas Engineering operator interface

The maintained source is `lward27/lucas_engineering`, `tools/cluster-ops`. Install with its `install.py`; it snapshots prior installed files and records hashes. The installed entry point is `~/.local/bin/lucas-ops`. `~/.local/share/lucas-ops/current` identifies the exact installed source. The profile inside that installation contains expected identities and credential references, never values.

Use `lucas-ops doctor` for read-only platform readiness. Add `--credentials` when the session authorizes using the three named PHarness/GitHub credentials; add `--builder` to check BuildKit mTLS and advertised AMD64 support. Use `--output ASTRA-READINESS.json` for an immutable receipt. A doctor pass does not prove an actual build, source write, or application acceptance.

Use `lucas-ops builder preflight --repo CLEAN_PHARNESS_WORKTREE --source-revision FULL_MERGED_SHA --output ASTRA-AMD64.json` when uncached AMD64 execution proof is required. It delegates to the existing platform-check script, uses the named Rancher Desktop client and desktop builder, and can temporarily open its own SSH route. It does not push an image or switch builders.

Use `lucas-ops evaluation status ID --output-dir PATH` or `evaluation watch ID --output-dir PATH --deadline 600`. These read the durable PHarness record even after Kubernetes deletes a completed evaluation Job. A watch can be interrupted and resumed with the same ID. Each read can reconnect its own localhost-only tunnel; writes are never automatically replayed.

`evaluation start` is an effectful command. Supply a reviewed request JSON file, full source revision, current native registry hash, policy identity and a unique operation ID. The native API retains its qualification guards. A record is created before the one POST. An uncertain record requires reconciliation; changing its name to retry is not reconciliation. Protocol calibration remains a separately authorized native operation. Never manufacture a qualification or lower a threshold through a helper.

Use `lucas-ops release verify --manifest FILE --output ASTRA-ARTIFACTS.json` to verify all seven PHarness image/config digests, platform and OCI source labels, plus the native bundle checksum. `release pin --manifest FILE --repo CLEAN_WORKTREE --output ASTRA-PIN.json` delegates local pin edits to PHarness's existing script and renders the real Argo values. It does not merge or deploy. Follow the repository procedure for native-bundle internals, tests, server dry-run and rollout evidence.

Use the shared classifier's `--argv-json` input for new callers. Its verdict is advisory; it does not parse every possible shell or grant execution authority. Unknown/compound commands need explicit inspection. Failed dry-runs and unknown GitOps ownership stop mutation preflight.

For long acceptance windows, use the existing application/cluster Job and durable result mechanisms. A laptop watch reports their state; its tunnel lifetime is not the measurement lifetime. A transport interruption creates missing observation, never evidence of an application regression or permission to roll back.

The separate LEA/Talos context resolves as `admin@lucas-engineering-agent-homelab` at `https://192.168.20.5:6443`. The global mapping is read-only. Do not infer that the word “agents” identifies `lucas_engineering` or `lucas-engineering-v2`.
