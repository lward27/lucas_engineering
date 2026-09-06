# ASTRA: Retire unused applications from lucas_engineering

Status: retention preparation reviewed; application removal has not yet been merged.

## Authorized scope

The owner requested decommissioning Odoo, Clawspace/OpenClaw, Epheros, Uptime Kuma and Code Server through this GitOps repository. This authorizes retirement of the six named Argo applications and their application-owned compute, services, ingress and permissions. Stored data is retained. LEA cluster retirement is a separate decision.

Baseline source: `04a98931af43b6ea1d189369442f6a1b76dda589`. Target: context `lucas_engineering`, API `https://192.168.20.192:6443`, kubeconfig `/Users/wardl/.kube/config`. The original checkouts and unrelated workloads are preserved.

## Exact application resource scope

The following direct resources come from the live Argo inventory. Deleting their owning workloads also removes dependent ReplicaSets and Pods. Ingress-owned certificates may be removed by garbage collection; externally managed credentials are retained with their namespaces.

| Argo application | Namespace | Resource | Action |
| --- | --- | --- | --- |
| clawspace | apps-prod | Service `clawspace` | Remove |
| clawspace | apps-prod | Deployment `clawspace` | Remove |
| clawspace | apps-prod | Ingress `clawspace` | Remove |
| code-server | code-server | ConfigMap `code-server-config` | Remove |
| code-server | code-server | PersistentVolumeClaim `code-server-data` | Retain |
| code-server | code-server | Service `code-server` | Remove |
| code-server | code-server | ServiceAccount `code-server` | Remove |
| code-server | code-server | Deployment `code-server` | Remove |
| code-server | code-server | Ingress `code-server` | Remove |
| code-server | code-server | NetworkPolicy `code-server` | Remove |
| code-server | cluster | ClusterRole `code-server-cluster-access` | Remove |
| code-server | cluster | ClusterRoleBinding `code-server-cluster-access` | Remove |
| epheros | cluster | Namespace `epheros` | Retain |
| epheros | epheros | Service `epheros-api` | Remove |
| epheros | epheros | Service `epheros-web` | Remove |
| epheros | epheros | ServiceAccount `epheros-api` | Remove |
| epheros | epheros | ServiceAccount `epheros-backup` | Remove |
| epheros | epheros | ServiceAccount `epheros-migrate` | Remove |
| epheros | epheros | ServiceAccount `epheros-web` | Remove |
| epheros | epheros | Deployment `epheros-api` | Remove |
| epheros | epheros | Deployment `epheros-web` | Remove |
| epheros | epheros | Ingress `epheros` | Remove |
| epheros | epheros | NetworkPolicy `api-ingress-egress` | Remove |
| epheros | epheros | NetworkPolicy `backup-egress` | Remove |
| epheros | epheros | NetworkPolicy `default-deny` | Remove |
| epheros | epheros | NetworkPolicy `migration-egress` | Remove |
| epheros | epheros | NetworkPolicy `web-ingress` | Remove |
| epheros | epheros | PodDisruptionBudget `epheros-api` | Remove |
| epheros | epheros | PodDisruptionBudget `epheros-web` | Remove |
| odoo | odoo | PersistentVolumeClaim `odoo` | Retain |
| odoo | odoo | Service `odoo` | Remove |
| odoo | odoo | Service `odoo-postgresql` | Remove |
| odoo | odoo | Service `odoo-postgresql-hl` | Remove |
| odoo | odoo | ServiceAccount `odoo` | Remove |
| odoo | odoo | ServiceAccount `odoo-postgresql` | Remove |
| odoo | odoo | Deployment `odoo` | Remove |
| odoo | odoo | StatefulSet `odoo-postgresql` | Remove |
| odoo | odoo | Ingress `odoo` | Remove |
| odoo | odoo | NetworkPolicy `odoo` | Remove |
| odoo | odoo | NetworkPolicy `odoo-postgresql` | Remove |
| odoo | odoo | PodDisruptionBudget `odoo` | Remove |
| odoo | odoo | PodDisruptionBudget `odoo-postgresql` | Remove |
| openclaw | apps-prod | ConfigMap `openclaw-agent-workspace-init` | Remove |
| openclaw | apps-prod | ConfigMap `openclaw-config` | Remove |
| openclaw | apps-prod | ConfigMap `openclaw-dashboard-custom` | Remove |
| openclaw | apps-prod | ConfigMap `openclaw-dashboard-instance` | Remove |
| openclaw | apps-prod | ConfigMap `openclaw-workspace` | Remove |
| openclaw | apps-prod | Service `openclaw` | Remove |
| openclaw | apps-prod | ServiceAccount `openclaw` | Remove |
| openclaw | apps-prod | StatefulSet `openclaw` | Remove |
| openclaw | apps-prod | Ingress `openclaw` | Remove |
| openclaw | apps-prod | NetworkPolicy `openclaw-custom` | Remove |
| openclaw | cluster | ClusterRoleBinding `openclaw-cluster-admin` | Remove |
| uptime-kuma | monitoring | PersistentVolumeClaim `uptime-kuma-pvc` | Retain |
| uptime-kuma | monitoring | Service `uptime-kuma` | Remove |
| uptime-kuma | monitoring | Deployment `uptime-kuma` | Remove |
| uptime-kuma | monitoring | Ingress `uptime-kuma` | Remove |

## Retained data and shared services

| Namespace | Claim | Requested storage |
| --- | --- | --- |
| apps-prod | `openclaw-data` | 10Gi |
| code-server | `code-server-data` | 30Gi |
| monitoring | `uptime-kuma-pvc` | 4Gi |
| odoo | `data-odoo-postgresql-0` | 8Gi |
| odoo | `odoo` | 10Gi |

These five bound claims request 62 GiB. This is allocation, not a measured backup or recoverable disk saving. Their recorded UIDs and PV bindings must remain unchanged after retirement. The OpenClaw claim is shared with Clawspace and has no workload owner reference. The Odoo PostgreSQL claim also has no owner reference; its StatefulSet has `Retain` deletion/scaling policy. No claim, PV, namespace, database, registry image, or external secret is approved for erasure.

Epheros uses `postgresql.apps-prod.svc.cluster.local`, database `epheros`; the shared PostgreSQL application and the database are retained. Finance, PHarness, LGTM, Tekton, the registry, and other Argo applications remain enabled. Epheros CI is already disabled and no live Epheros Pipeline/trigger was found.

## Two GitOps stages

1. Merge retention preparation: apply `Prune=false,Delete=false` to Odoo, Code Server and Uptime Kuma claims, and to the Epheros namespace. Disable the Epheros migration hook so retention sync cannot run `alembic upgrade head`. Wait for the exact annotations and unchanged claim identities live. The Uptime Kuma wrapper adopts the same claim name because its pinned upstream chart cannot annotate its PVC; rendered workload and storage specifications must remain identical.
2. Only after those checks pass, disable exactly six root-app entries. Preserve namespace declarations and the chart sources for restoration. Remove their Homepage bookmarks/widget and the three dedicated OpenClaw/Epheros Prometheus targets. Let the existing root-app prune and application finalizers remove the reviewed resources. Verify deletion and retained data identities.

Argo documents `Delete=false` for retaining resources during Application deletion and `Prune=false` for sync pruning: [Argo sync options](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#no-resource-deletion). No finalizer bypass or direct workload deletion is required.

## Validation and recovery

[Baseline inventory](ASTRA-APPLICATION-RETIREMENT-BASELINE.json) and [retention validation](ASTRA-APPLICATION-RETENTION-VALIDATION.json) retain exact observations. Local rendering and Helm lint must pass; only retention annotations and removal of the migration hook may differ in the preparation stage. Client and server dry-runs cover the four retained resources. Live annotations and claim UIDs are the gate to removal.

Rollback means a reviewed GitOps change re-enabling the selected app with the retained chart and the same claim names. Keep the data protections. Epheros migrations remain disabled until explicitly reviewed against the retained database. Re-enabling an application restores its network exposure; do not do so as an automatic response to successful retirement. No restore has been tested.

Cloudflared is remotely managed by token; this repository contains no per-host tunnel or DNS configuration. Its shared deployment and external Cloudflare entries remain. Removing the Kubernetes ingresses removes these application origins. External DNS/Access entry deletion, database erasure and storage deletion are outside this change.

## Completion evidence

Pending: merged revisions, live retention gate, exact removal verification, Homepage/Prometheus observed updates, unrelated application comparison.
