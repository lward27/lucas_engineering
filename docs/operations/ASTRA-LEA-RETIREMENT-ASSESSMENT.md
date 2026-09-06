# ASTRA: LEA retirement assessment

Status: assessed read-only on 2026-09-06. Retirement is being considered, not authorized. Nothing was stopped, drained, deleted, scaled down or migrated.

## Identity and current footprint

“LEA / lucas-engineering-agents-cluster” maps to the dedicated Talos cluster `admin@lucas-engineering-agent-homelab`, API `https://192.168.20.5:6443`. It is separate from `lucas_engineering` at `https://192.168.20.192:6443` and the Flux-based `lucas-engineering-v2` cluster. The [retained inventory](ASTRA-LEA-RETIREMENT-INVENTORY.json) records the observed resources and source revisions.

Six nodes are Ready: one control plane, three general workers and two sandbox workers. The current infrastructure source (`ac532d5f1ec7e9ff1a2a77230d14de451ef44d8b`) allocates those VMs **26 vCPUs, 40 GiB RAM and 400 GB of virtual disks**. VM IDs are 201, 204, 205, 206, 207 and 208. Two additional control-plane entries are already marked inactive; they are not counted as fresh savings.

These are configured VM allocations. Host free memory, physical CPU capacity, actual disk allocation and reclaimable storage were not measured. Replacing VMs on the same physical host can provide scheduling capacity but does not create another host failure domain.

## What would be retired

The cluster has 22 Argo applications, including the LEA application itself: agent/control/tool/artifact APIs, sandbox manager, web console, PostgreSQL, object storage, its release pipeline, Cloudflare ingress, and observability. The observed PipelineRuns were completed; that snapshot does not prevent new webhook-triggered work from arriving later.

Seven bound PVCs request **116 GiB**:

| Data | Requested storage |
| --- | ---: |
| PostgreSQL | 40 GiB |
| Garage object data and metadata | 21 GiB |
| Prometheus | 20 GiB |
| Loki | 20 GiB |
| Tempo | 10 GiB |
| Grafana | 5 GiB |

There is also a deliberately retained 64 MiB validation PV. All observed PVs use `Retain`. That setting does not protect data when their VM disks are deleted. PostgreSQL reports healthy, but its current Cluster resource has no backup configuration or reported successful backup; a separate manual backup may exist, and no restore was verified here.

## Recommendation and required decisions

Consolidation fits the PHarness program's focus on `lucas_engineering`, provided the owner is comfortable retiring the independent LEA product environment. Treat this as an application/data retirement before treating it as spare compute.

1. Decide whether to preserve LEA for restoration or permanently discard it, and set retention for PostgreSQL, artifacts, audit history and telemetry.
2. Verify recoverable exports of the chosen data, plus the GitOps/infrastructure revisions and required secret-management recovery references. Test restoration before deleting the original disks.
3. Identify and disable only LEA's external ingress and release triggers in their authoritative sources so new work cannot arrive during retirement.
4. Recheck cross-cluster consumers and the desktop builder. LEA's remote BuildKit service uses port 12341; `lucas_engineering` uses the separate K3s service on port 12340 on the same desktop. Retirement must preserve the latter and the shared registry.
5. Verify host inventory and actual reclaimable resources, then prepare a concrete VM/resource allowlist with recovery steps for owner approval. Shut down and observe before any disk deletion.
6. Size new K3s workers from the measured host budget, leaving control-plane and storage headroom. Record their authoritative infrastructure configuration and validate scheduling and service behavior after joining them.

The existing LEA GitOps and infrastructure checkouts contain user-owned edits. They were preserved. Any retirement implementation should use fresh worktrees in `lward27/lucas-engineering-agent-gitops` and `lward27/lucas-engineering-infrastructure`.
