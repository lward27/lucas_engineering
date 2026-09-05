# ASTRA: Restore the desktop BuildKit endpoint

## Requested change

The owner reported that `lucas-desktop` was available again on 2026-09-05.
Restore the established K3s desktop endpoint after checking it independently.
The temporary M1 fallback remains documented; builder selection is explicit.

## Target and repository convention

Context `lucas_engineering`, namespace `tekton-pipelines`, Argo Application
`tekton-ci`, Helm chart `charts/tekton-ci`. Change the address in the existing
`EndpointSlice/k3s-buildkit-ipv4` from `192.168.2.2` to `192.168.50.145`.
The Service, TCP port 12340, TLS server name `buildkit-k3s.lucas.internal`,
credentials, Task, Pipeline results and permissions remain the same.
This is an authorized, non-destructive GitOps change. No host configuration,
other cluster, application deployment, cache deletion or build cancellation is
part of the restoration.

## Observed prerequisites

At 22:00 UTC, the desktop's K3s BuildKit v0.32.2 was active with zero restarts,
an 8 GiB service memory limit and about 300 GiB free on its build volume.
The existing local `lucas-desktop` builder connected through an SSH forward
from `127.0.0.1:12342` to `192.168.50.145:12340`, retaining mutual TLS and
hostname verification. Uncached Linux AMD64 execution passed on that worker.
The Mac cannot connect directly to port 12340 because the existing desktop
firewall limits that listener to the cluster nodes and desktop itself.

The bounded cluster Job `astra-m02-desktop-return-preflight-20260905`, UID
`5e553e3a-d608-4134-825f-414a30b40b98`, ran from 22:01:28 to 22:02:49 UTC.
It connected directly to the desktop using the existing Tekton client Secret,
executed uncached AMD64 instructions, generated a 112 MiB random layer and
pushed it through the existing private TLS registry route. Its image is:

`registry.lucas.engineering/buildkit-smoke@sha256:0152b21495be91ddd3cfc3df74dde54b20df6150652eef5697ef1ebe48c6168d`

This is infrastructure evidence, not autonomous source delivery or Finance
application acceptance. PHarness retains the sanitized Job, build result and
logs under `planning/evidence/autonomous-sdlc/ASTRA-M02-DESKTOP-*`.

## Validation and rollout

Helm lint, rendering and server dry-run of the Service/EndpointSlice passed.
Before merging, require the exact-digest pull/run check and no active Tekton
PipelineRuns. Review the rendered diff: only the EndpointSlice address changes.
After merging, observe Argo's exact GitOps revision and live EndpointSlice,
then execute a bounded build through the Service address. Keep direct-host
preflight and Service-route acceptance separately recorded. Auto-sync performs
the rollout; do not patch the live EndpointSlice or force a sync.

## Recovery and limitations

If the desktop becomes unavailable, retain the failed build evidence and
reconcile any active operations before a retry. To restore the Mac fallback,
verify its actual VPN address, start its dedicated BuildKit and SSH forward,
complete its mutual-TLS/AMD64/registry checks, then submit the narrowly scoped
GitOps endpoint change. Do not switch a running build silently.

The prior Mac release build exhausted its 4 GiB Rancher Desktop VM during Rust
compilation and published no release image. A request to increase the saved
VM memory setting to 6 GiB had not changed the observed 4 GiB allocation before
the desktop returned. Do not describe the Mac fallback as sufficient for that
release until it is measured again. The Mac forward was closed during that
recovery; its dedicated container and cache were retained.

No destructive operation was performed. Returning to the desktop does not
close the PHarness coding qualification or unattended-operation gates.
