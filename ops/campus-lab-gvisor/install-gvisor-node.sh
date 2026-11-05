#!/usr/bin/env bash
# Idempotent gVisor (runsc) setup for a PHarness Campus lab node.
#
# Runs as root on the node itself (run-on-node.sh does that through a
# temporary privileged Pod). It changes only:
#   /usr/local/bin/runsc, /usr/local/bin/containerd-shim-runsc-v1
#   /var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl
#   /etc/rancher/k3s/config.yaml.d/50-pharness-campus-lab.yaml
#   /etc/systemd/system/kubepods.slice.d/50-pharness-campus-noswap.conf
#   /etc/rancher/k3s/config.yaml.d/60-pharness-campus-kubelet.yaml
# and restarts k3s-agent only when the containerd template or the kubelet
# drop-in changed (or k3s-agent predates them) and --allow-restart was given.
# --check reports drift and changes nothing.
set -euo pipefail

GVISOR_RELEASE="20261026.0"
ARCH="x86_64"
BASE_URL="https://storage.googleapis.com/gvisor/releases/release/${GVISOR_RELEASE}/${ARCH}"
# Upstream gvisor.tar.bz2.sha512 for release-20261026.0, and the binaries it
# contains, verified on 2026-11-05 against the LUC-114 install.
TARBALL_SHA512="26e4a327565f5da0f73261a6387e2c20f4695a232e330095a3111b70efd604fdf09d734e8cc8f714dbb5c5607ce8c87ea80b26df549d83a146f2efd5a1af448a"
RUNSC_SHA512="e656d169e5761482b5cfd081e73e0014158843fe82366274d0bfa5d9716d6352514617fb680d28b7a11e6e2796f4790a3262b75f0cc6414207c4012a2139fa21"
SHIM_SHA512="4e5361092a17a17425d7e9e1d328b4d9769342c4b9803400d3a2beb8706e8d204719b55d2fdc74e6894affe2af63200f19ccfe732d90c4418fb2520e2eda6467"
NODE_LABEL="pharness.dev/campus-lab-runtime=gvisor"

CONTAINERD_DIR="/var/lib/rancher/k3s/agent/etc/containerd"
TEMPLATE="${CONTAINERD_DIR}/config-v3.toml.tmpl"
TEMPLATE_BACKUP="/root/containerd-config.toml.pre-gvisor"
K3S_DROPIN_DIR="/etc/rancher/k3s/config.yaml.d"
K3S_DROPIN="${K3S_DROPIN_DIR}/50-pharness-campus-lab.yaml"
SWAP_DROPIN_DIR="/etc/systemd/system/kubepods.slice.d"
SWAP_DROPIN="${SWAP_DROPIN_DIR}/50-pharness-campus-noswap.conf"
KUBEPODS_CGROUP="/sys/fs/cgroup/kubepods.slice"
KUBELET_DROPIN="${K3S_DROPIN_DIR}/60-pharness-campus-kubelet.yaml"
BACKUP_DIR="/root/pharness-campus-backups"

MODE=apply
ALLOW_RESTART=false
for arg in "$@"; do
  case "$arg" in
    --check) MODE=check ;;
    --allow-restart) ALLOW_RESTART=true ;;
    *) echo "usage: $0 [--check] [--allow-restart]" >&2; exit 2 ;;
  esac
done
[[ "$(id -u)" == 0 ]] || { echo "must run as root on the node" >&2; exit 2; }
[[ "$(uname -m)" == "$ARCH" ]] || { echo "unsupported architecture $(uname -m)" >&2; exit 2; }

DRIFT=0
note() { printf '%s\n' "$*"; }
drift() { note "DRIFT  $*"; DRIFT=1; }

sha512_of() { sha512sum "$1" | cut -d' ' -f1; }

desired_template() {
  cat <<'TOML'
{{ template "base" . }}

# gVisor for PHarness Campus lab slots. Managed by
# lucas_engineering ops/campus-lab-gvisor/install-gvisor-node.sh.
[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
TOML
}

desired_dropin() {
  cat <<YAML
# Managed by lucas_engineering ops/campus-lab-gvisor. k3s applies node labels
# when the node registers; run-on-node.sh also labels the live Node object.
node-label:
  - "${NODE_LABEL}"
YAML
}

# The kubelet's NoSwap behaviour sets memory.swap.max=0 on container cgroups
# only. runsc-sandbox and runsc-gofer run in the Pod sandbox cgroup, which has
# no swap limit, so a gVisor session above its memory limit spills into node
# swap instead of being OOM-killed. Every runc process on the node already has
# memory.swap.max=0, so capping the whole kubepods.slice changes only pause
# containers and gVisor sandboxes.
desired_swap_dropin() {
  cat <<'INI'
# Managed by lucas_engineering ops/campus-lab-gvisor/install-gvisor-node.sh.
# Keeps gVisor sandboxes (and pause containers) out of node swap; runc
# containers already get memory.swap.max=0 from the kubelet.
[Slice]
MemorySwapMax=0
INI
}

# Values come from node 2 measurements on 2026-11-06 (ops/campus-lab-gvisor/README.md).
# eviction-hard replaces the k3s default map, so it repeats the k3s disk
# thresholds (5%) and adds the memory signal that map leaves out.
desired_kubelet_dropin() {
  cat <<'YAML'
# Managed by lucas_engineering ops/campus-lab-gvisor/install-gvisor-node.sh.
# Kubelet hardening for the Campus lab node; k3s-agent must restart to apply.
kubelet-arg+:
  - "pod-max-pids=4096"
  - "kube-reserved=cpu=500m,memory=1536Mi"
  - "system-reserved=cpu=250m,memory=512Mi"
  - "eviction-hard=memory.available<500Mi,nodefs.available<5%,imagefs.available<5%,nodefs.inodesFree<5%"
YAML
}

backup_file() {
  [[ -f "$1" ]] || return 0
  install -d -m 0700 "$BACKUP_DIR"
  cp -p "$1" "${BACKUP_DIR}/$(basename "$1").$(date +%Y%m%dT%H%M%S)"
}

binaries_current() {
  [[ -x /usr/local/bin/runsc && -x /usr/local/bin/containerd-shim-runsc-v1 ]] &&
    [[ "$(sha512_of /usr/local/bin/runsc)" == "$RUNSC_SHA512" ]] &&
    [[ "$(sha512_of /usr/local/bin/containerd-shim-runsc-v1)" == "$SHIM_SHA512" ]]
}

install_binaries() {
  local work
  work="$(mktemp -d /root/gvisor-install.XXXXXX)"
  trap 'rm -rf -- "$work"' RETURN
  curl -fsSL --proto '=https' --tlsv1.2 --max-time 300 -o "${work}/gvisor.tar.bz2" "${BASE_URL}/gvisor.tar.bz2"
  curl -fsSL --proto '=https' --tlsv1.2 --max-time 60 -o "${work}/gvisor.tar.bz2.sha512" "${BASE_URL}/gvisor.tar.bz2.sha512"
  [[ "$(sha512_of "${work}/gvisor.tar.bz2")" == "$TARBALL_SHA512" ]] || { echo "tarball sha512 mismatch" >&2; exit 1; }
  [[ "$(cut -d' ' -f1 "${work}/gvisor.tar.bz2.sha512")" == "$TARBALL_SHA512" ]] || { echo "published sha512 differs from the pin" >&2; exit 1; }
  # Ubuntu nodes ship python3 but not bzip2.
  python3 - "${work}/gvisor.tar.bz2" "${work}/x" <<'PY'
import sys, tarfile
with tarfile.open(sys.argv[1], "r:bz2") as archive:
    names = ("runsc", "containerd-shim-runsc-v1")
    wanted = [m for m in archive.getmembers() if m.isfile() and m.name.removeprefix("./") in names]
    if len(wanted) != 2:
        sys.exit("release archive does not contain runsc and containerd-shim-runsc-v1")
    archive.extractall(sys.argv[2], members=wanted, filter="data")
PY
  [[ "$(sha512_of "${work}/x/runsc")" == "$RUNSC_SHA512" ]] || { echo "runsc sha512 mismatch" >&2; exit 1; }
  [[ "$(sha512_of "${work}/x/containerd-shim-runsc-v1")" == "$SHIM_SHA512" ]] || { echo "shim sha512 mismatch" >&2; exit 1; }
  install -o root -g root -m 0755 "${work}/x/runsc" /usr/local/bin/runsc
  install -o root -g root -m 0755 "${work}/x/containerd-shim-runsc-v1" /usr/local/bin/containerd-shim-runsc-v1
}

TEMPLATE_CHANGED=false
KUBELET_CHANGED=false

if binaries_current; then
  note "OK     runsc and containerd-shim-runsc-v1 are release-${GVISOR_RELEASE}"
elif [[ "$MODE" == check ]]; then
  drift "gVisor binaries missing or not release-${GVISOR_RELEASE}"
else
  install_binaries
  note "CHANGED installed gVisor release-${GVISOR_RELEASE}"
fi

if [[ -f "$TEMPLATE" ]] && cmp -s <(desired_template) "$TEMPLATE"; then
  note "OK     ${TEMPLATE}"
elif [[ "$MODE" == check ]]; then
  drift "${TEMPLATE} differs from the managed template"
else
  if [[ ! -e "$TEMPLATE_BACKUP" && -f "${CONTAINERD_DIR}/config.toml" ]]; then
    cp -p "${CONTAINERD_DIR}/config.toml" "$TEMPLATE_BACKUP"
  fi
  desired_template >"${TEMPLATE}.new"
  chmod 0644 "${TEMPLATE}.new"
  mv -f "${TEMPLATE}.new" "$TEMPLATE"
  TEMPLATE_CHANGED=true
  note "CHANGED wrote ${TEMPLATE}"
fi

if [[ -f "$K3S_DROPIN" ]] && cmp -s <(desired_dropin) "$K3S_DROPIN"; then
  note "OK     ${K3S_DROPIN}"
elif [[ "$MODE" == check ]]; then
  drift "${K3S_DROPIN} missing or different"
else
  install -d -m 0755 "$K3S_DROPIN_DIR"
  desired_dropin >"${K3S_DROPIN}.new"
  chmod 0644 "${K3S_DROPIN}.new"
  mv -f "${K3S_DROPIN}.new" "$K3S_DROPIN"
  note "CHANGED wrote ${K3S_DROPIN}"
fi

if [[ -f "$SWAP_DROPIN" ]] && cmp -s <(desired_swap_dropin) "$SWAP_DROPIN"; then
  note "OK     ${SWAP_DROPIN}"
elif [[ "$MODE" == check ]]; then
  drift "${SWAP_DROPIN} missing or different"
else
  install -d -m 0755 "$SWAP_DROPIN_DIR"
  desired_swap_dropin >"${SWAP_DROPIN}.new"
  chmod 0644 "${SWAP_DROPIN}.new"
  mv -f "${SWAP_DROPIN}.new" "$SWAP_DROPIN"
  systemctl daemon-reload
  note "CHANGED wrote ${SWAP_DROPIN}"
fi

if [[ "$(cat "${KUBEPODS_CGROUP}/memory.swap.max")" == 0 ]]; then
  note "OK     ${KUBEPODS_CGROUP}/memory.swap.max is 0"
elif [[ "$MODE" == check ]]; then
  drift "${KUBEPODS_CGROUP}/memory.swap.max is $(cat "${KUBEPODS_CGROUP}/memory.swap.max")"
else
  # kubepods.slice is a transient unit the kubelet creates; apply the value
  # to the running slice as well as through the drop-in.
  systemctl set-property --runtime kubepods.slice MemorySwapMax=0
  [[ "$(cat "${KUBEPODS_CGROUP}/memory.swap.max")" == 0 ]] || { echo "kubepods.slice swap limit did not apply" >&2; exit 1; }
  note "CHANGED set kubepods.slice MemorySwapMax=0"
fi

if [[ -f "$KUBELET_DROPIN" ]] && cmp -s <(desired_kubelet_dropin) "$KUBELET_DROPIN"; then
  note "OK     ${KUBELET_DROPIN}"
elif [[ "$MODE" == check ]]; then
  drift "${KUBELET_DROPIN} missing or different"
else
  install -d -m 0755 "$K3S_DROPIN_DIR"
  backup_file "$KUBELET_DROPIN"
  desired_kubelet_dropin >"${KUBELET_DROPIN}.new"
  chmod 0644 "${KUBELET_DROPIN}.new"
  mv -f "${KUBELET_DROPIN}.new" "$KUBELET_DROPIN"
  KUBELET_CHANGED=true
  note "CHANGED wrote ${KUBELET_DROPIN}"
fi

# k3s reads config.yaml.d only at start, so a drop-in newer than the running
# k3s-agent has not reached the kubelet yet.
if [[ "$KUBELET_CHANGED" != true && -f "$KUBELET_DROPIN" ]]; then
  agent_start="$(date -d "$(systemctl show k3s-agent -p ExecMainStartTimestamp --value)" +%s)"
  if (( "$(stat -c %Y "$KUBELET_DROPIN")" < agent_start )); then
    note "OK     k3s-agent started after ${KUBELET_DROPIN}"
  else
    drift "k3s-agent started before ${KUBELET_DROPIN}; it needs a restart"
  fi
fi

# k3s renders config.toml from the template when k3s-agent starts.
if grep -q "runtimes.runsc\]" "${CONTAINERD_DIR}/config.toml" 2>/dev/null; then
  note "OK     rendered config.toml registers the runsc handler"
elif [[ "$TEMPLATE_CHANGED" != true ]]; then
  drift "rendered config.toml does not register runsc; k3s-agent needs a restart"
fi

if [[ "$TEMPLATE_CHANGED" == true || "$KUBELET_CHANGED" == true || "$DRIFT" == 1 && "$MODE" == apply ]]; then
  if [[ "$ALLOW_RESTART" == true ]]; then
    # The restart also restarts the kubelet that carries this exec session,
    # so it runs detached; run-on-node.sh verifies with --check afterwards.
    systemd-run --quiet --collect --unit="pharness-campus-k3s-agent-restart-$(date +%s)" \
      --on-active=3s /usr/bin/systemctl restart k3s-agent
    note "SCHEDULED k3s-agent restart in 3s"
    exit 4
  else
    note "PENDING k3s-agent restart required (rerun with --allow-restart)"
    exit 3
  fi
fi

/usr/local/bin/runsc --version | head -1
if [[ "$MODE" == check && "$DRIFT" == 1 ]]; then
  exit 1
fi
