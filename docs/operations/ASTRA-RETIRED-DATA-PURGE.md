# ASTRA: Purge retired application data

Status: complete, verified 2026-09-06. All five approved PVCs and PVs are absent, their local-path teardown completed, and the Epheros database and its original data directory are absent.

The owner explicitly authorized: “Go ahead and purge the PVCs and databases. I do not need the data, it is safe to delete.” This supersedes the data-retention boundary of the earlier application retirement. The target remains `lucas_engineering`, API `https://192.168.20.192:6443`, kubeconfig `/Users/wardl/.kube/config`. Source baseline: `cb53787ec62443e76738ef6418d4314bc3efefe0`.

## Exact destructive allowlist

| Namespace | Claim | Claim UID | Requested capacity |
| --- | --- | --- | --- |
| apps-prod | `openclaw-data` | `3c099e8a-bea8-4641-9a14-dcff30cdf8ff` | 10Gi |
| code-server | `code-server-data` | `bff78087-5f5f-44a1-b705-a5e0c64d4480` | 30Gi |
| monitoring | `uptime-kuma-pvc` | `f70da283-45c1-44db-9bc0-14cd23ede08e` | 4Gi |
| odoo | `data-odoo-postgresql-0` | `504241f0-6aa9-46e1-905a-298321eed19c` | 8Gi |
| odoo | `odoo` | `e858df73-763b-4984-b15e-c3b3fd2dd03d` | 10Gi |

At preflight, these five claims had no mounting Pods or owner references. All five PVs used `Delete` reclamation. The local-path provisioner subsequently confirmed deletion of their exact backing directories. The 62 GiB sum is requested capacity, not measured disk usage or physical space reclaimed. Odoo PostgreSQL data was inside `odoo/data-odoo-postgresql-0`; Uptime Kuma storage and OpenClaw/Clawspace state were inside their corresponding application claims.

Database deletion was limited to `epheros`, OID `406059`, owner `epheros_owner`, on `apps-prod/postgresql-0` / service `postgresql.apps-prod.svc.cluster.local`. It had zero active sessions, prepared transactions, or logical replication slots at preflight and occupied 8,926,899 bytes. The shared PostgreSQL Pod and claim `apps-prod/pgdata-postgresql-0` remain. Database identities for `datalog_visual`, `finance_app`, `postgres`, `template0`, `template1`, and `testdb` were verified unchanged afterward.

The six retired Argo applications remain absent and disabled. Their retained data objects were orphaned by the preceding retirement; no active application controller remained to prune them. This authorized purge therefore used one-time explicit deletions, recorded here in the GitOps repository. No chart was re-enabled. Namespaces, secrets, roles, external Cloudflare entries, LEA, registry images and unrelated PVCs/databases were outside this purge. No new backup was made.

## Execution and safeguards

Every Kubernetes operation used the exact kubeconfig/context. Target identities and absence of mounting Pods were rechecked. The four deliberately dispatched storage deletions used fresh UID/resourceVersion preconditions, durable command receipts and no automatic retries. The existing provisioner removed backing directories; no finalizers were bypassed and no direct PV or host-path deletion was performed.

The first intended storage dry run was an execution error: I sent a raw DELETE for `apps-prod/openclaw-data` with `dryRun=All` in its URL but a nonempty DeleteOptions body that omitted `dryRun`. Kubernetes decodes the body instead of the URL options in that case, so the claim was actually deleted at 21:04:46 UTC. This was within the owner's approved purge allowlist, but earlier than intended. The following presence check failed, stopping further volume requests while the cause was investigated. The [Kubernetes 1.34.4 DELETE handler](https://github.com/kubernetes/kubernetes/blob/v1.34.4/staging/src/k8s.io/apiserver/pkg/endpoints/handlers/delete.go#L78-L115) confirms this behavior; the live server was `v1.34.4+k3s1`.

For the other four claims, normal `kubectl delete pvc … --dry-run=server --wait=false` passed and a subsequent read proved each still existed. Their actual deletions were then dispatched at 21:06:54 UTC. **There were four successful dry runs, not five.** Raw DELETE requests with a body must carry any dry-run setting in that body; use the normal kubectl resource command for routine dry runs. The initial response was not saved before the failed presence check, so its exact resourceVersion is not reconstructed. The original UID, matched teardown logs and observed absence are preserved.

The reviewed SQL payload connected to `postgres`, checked the target OID/owner and zero sessions, and executed at 21:05:15–21:05:16 UTC:

```sql
DROP DATABASE "epheros";
```

The command used `psql -X` with `ON_ERROR_STOP`, bounded lock/statement timeouts, and no force option or connection termination. The existing database Pod credential passed via its process environment to psql; it was never displayed or copied into local arguments/evidence. Final verification found neither the catalog entry nor its original `base/406059` directory.

PostgreSQL documents that [DROP DATABASE](https://www.postgresql.org/docs/17/sql-dropdatabase.html) removes the database catalog entry and data directory and is irreversible. The [local-path provisioner](https://github.com/rancher/local-path-provisioner) owns volume teardown; live configuration here uses its normal directory-removal script. This is logical/data-file deletion, not a secure-erasure claim for underlying storage media or external backups.

## Acceptance evidence

- [Storage preflight](ASTRA-RETIRED-DATA-PURGE-PREFLIGHT.json): exact five claim/PV identities, paths, node placement, no mounts, and 85 unrelated claims.
- [Database preflight](ASTRA-RETIRED-DATABASE-PREFLIGHT.json): target identity, zero sessions and all database identities.
- [Initial deletion observation](ASTRA-PURGE-INITIAL-DELETE-OBSERVATION.json): the OpenClaw request-construction error, investigation and matched teardown logs. The provisioner repeated cleanup for this same volume and logged a subsequent PV NotFound retry; final absence was verified without intervention.
- [Four corrected dry runs](ASTRA-RETIRED-DATA-DELETE-DRY-RUN.json) and [actual PVC deletion receipts](ASTRA-RETIRED-PVC-PURGE-RECEIPT.json): exact requests and preconditions.
- [Database deletion receipt](ASTRA-RETIRED-DATABASE-PURGE-RECEIPT.json): guarded SQL, successful deletion, final directory/catalog absence and six unchanged database identities.
- [Final cluster verification](ASTRA-RETIRED-DATA-PURGE-VERIFIED.json): all five PVCs/PVs absent, five successful provisioner teardowns, all 85 unrelated claims unchanged, and shared PostgreSQL Ready with its original Pod UID and zero restarts.
- All six retired Applications remain absent. All 42 remaining Applications are Healthy; 41 are Synced. The pre-existing Healthy/OutOfSync state of `hermes-agent` is unchanged.

The root-app change updates retirement comments only; its rendered resources were verified identical to the recorded source baseline. All 20 local Markdown links and seven new JSON artifacts passed validation. This record supersedes the data-retention and restoration assumptions in the [earlier retirement record](ASTRA-APPLICATION-RETIREMENT.md).

After purge, re-enabling the old charts cannot recover this data. Any later deployment requires new storage/database initialization or an independently held backup. Earlier retirement evidence remains historical and must not be treated as proof that retained data still exists.
