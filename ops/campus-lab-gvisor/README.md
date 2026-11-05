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

Restarting `k3s-agent` on node 2 is allowed (KillMode=process keeps running
containers). k3s renders `config.toml` from the template on start.

## Rollback

1. Delete the slot workloads (`kubectl delete jobs --all -n campus-lab-slot-N`).
2. On the node: remove the template and the drop-in, restart `k3s-agent`, then
   delete `/usr/local/bin/runsc` and `/usr/local/bin/containerd-shim-runsc-v1`.
3. Disable `apps.campus-lab` in `charts/root-app/values.yaml`.

Without the handler, Pods with `runtimeClassName: gvisor` fail to start
(`no runtime for "runsc" is configured`); they never fall back to runc.
