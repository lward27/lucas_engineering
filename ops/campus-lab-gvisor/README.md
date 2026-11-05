# Campus lab gVisor node setup

PHarness Campus lab slots (`charts/campus-lab`) run student session Pods with
`runtimeClassName: gvisor`. Argo CD manages the RuntimeClass, slot namespaces,
quotas, RBAC and admission policy. The parts that live on the node's
filesystem cannot be managed by Argo, so they are kept here as an idempotent
script:

| Item | Value |
| --- | --- |
| Node | `ubuntu-lucas-engineering-2` (Ubuntu 24.04.5, kernel 6.8.0-147-generic, k3s v1.34.5+k3s1, containerd 2.1.5-k3s1, flannel vxlan with the embedded k3s network policy controller) |
| gVisor | `release-20261026.0`, `runsc` and `containerd-shim-runsc-v1` in `/usr/local/bin`, pinned by sha512 (tarball and binaries) |
| containerd | `/var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl` adds the `runsc` runtime (`io.containerd.runsc.v1`) to the k3s base template |
| Node label | `pharness.dev/campus-lab-runtime=gvisor`: on the live Node and in `/etc/rancher/k3s/config.yaml.d/50-pharness-campus-lab.yaml` for re-registration |
| Swap | `/etc/systemd/system/kubepods.slice.d/50-pharness-campus-noswap.conf` sets `MemorySwapMax=0` on `kubepods.slice` (also applied to the running slice). The kubelet's NoSwap behaviour limits swap only on container cgroups, while `runsc-sandbox` runs in the Pod sandbox cgroup; without this a session above its memory limit pages into node swap instead of being OOM-killed. runc containers already have `memory.swap.max=0`, so only pause containers and gVisor sandboxes change |
| Kubelet | `/etc/rancher/k3s/config.yaml.d/60-pharness-campus-kubelet.yaml` appends `kubelet-arg`: `pod-max-pids=4096`, `kube-reserved=cpu=500m,memory=1536Mi`, `system-reserved=cpu=250m,memory=512Mi`, `eviction-hard=memory.available<500Mi,nodefs.available<5%,imagefs.available<5%,nodefs.inodesFree<5%`. Applied by a k3s-agent restart; `--check` reports drift if the file differs or k3s-agent started before it was written |
| Backups | Earlier versions of the kubelet drop-in go to `/root/pharness-campus-backups/` |
| Original config | `/root/containerd-config.toml.pre-gvisor` (rendered `config.toml` before gVisor) |

## Usage

From an operator workstation with cluster-admin on `lucas_engineering`:

```sh
ops/campus-lab-gvisor/run-on-node.sh --check            # report drift, change nothing
ops/campus-lab-gvisor/run-on-node.sh                    # converge; exit 3 if a restart is needed
ops/campus-lab-gvisor/run-on-node.sh --allow-restart    # converge and restart k3s-agent if the template changed
```

`run-on-node.sh` creates the privileged namespace `campus-lab-hostops` with
one Pod pinned to the node, streams `install-gvisor-node.sh` into
`nsenter -t 1 ... bash -s` and deletes the namespace on exit, including on
failure. Nothing privileged stays running.

## Kubelet values

Measured on node 2 (16 CPU, 31.3 GiB, 4 GiB swap, `pid_max` 4194304,
`threads-max` 256094) on 2026-11-05, before the change:

- `k3s-agent.service` (kubelet, containerd, 49 shims) used about 250m CPU,
  440 MiB anonymous memory and 570 MiB kernel memory; its peak including page
  cache was 12.1 GiB, which is reclaimable. `kube-reserved` keeps 500m and
  1.5 GiB for it, with room for gVisor shims of five lab slots.
- The rest of `system.slice` used about 50 MiB anonymous memory and little
  CPU; `system-reserved` is 250m and 512 MiB.
- `eviction-hard` before the change was only the k3s default
  `imagefs.available<5%,nodefs.available<5%`, with no memory signal. The
  kubelet now evicts below 500 MiB available memory. The disk thresholds stay
  at 5% because the root filesystem is 83% full.
- The busiest Pod on the node peaked at 213 PIDs and all Pods together used
  about 900. A held fork bomb in a gVisor sandbox added 259 host threads
  (LUC-125). `pod-max-pids=4096` leaves an order of magnitude of headroom
  for both while bounding a runaway Pod far below `threads-max`.
- `enforceNodeAllocatable` stays at `pods`, so the reservations lower Node
  allocatable and the `kubepods.slice` limit but put no cgroup limit on
  k3s-agent or system services.

Restarting `k3s-agent` on node 2 is allowed (KillMode=process keeps running
containers). k3s renders `config.toml` from the template on start.

## Rollback

1. Delete the slot workloads (`kubectl delete jobs --all -n campus-lab-slot-N`).
2. To undo only the kubelet hardening: delete
   `/etc/rancher/k3s/config.yaml.d/60-pharness-campus-kubelet.yaml` (or
   restore a copy from `/root/pharness-campus-backups/`), remove the
   `desired_kubelet_dropin` block from `install-gvisor-node.sh` and restart
   `k3s-agent`. Pods created before the restart keep the PID limit they were
   created with until they are recreated.
3. On the node: remove the template, the k3s drop-ins and the kubepods.slice
   drop-in, run `systemctl daemon-reload` and
   `systemctl set-property --runtime kubepods.slice MemorySwapMax=infinity`,
   restart `k3s-agent`, then
   delete `/usr/local/bin/runsc` and `/usr/local/bin/containerd-shim-runsc-v1`.
4. Disable `apps.campus-lab` in `charts/root-app/values.yaml`.

Without the handler, Pods with `runtimeClassName: gvisor` fail to start
(`no runtime for "runsc" is configured`); they never fall back to runc.
