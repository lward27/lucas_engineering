# LocDoc OMS Terraform labs

The Lucas Engineering root Argo CD application manages four applications from
`main` in this repository:

| Argo application | Namespace | Purpose |
| --- | --- | --- |
| `localstack` | `localstack` | Community 4.12.0 API emulator |
| `aws-emulator` | `aws-emulator` | AWS Emulator 1.0.385 |
| `locdoc-localstack` | `localstack` | Isolated OMS with LocalStack-backed S3 |
| `locdoc-aws-emulator` | `aws-emulator` | Isolated OMS with AWS Emulator-backed S3 |

The original `locdoc` application, its database, bucket, credentials and PVCs
are independent. Each lab reuses the existing pinned OMS application image,
with a fresh synthetic database, captured mail and the local payment, supplier
and maps mocks. There is no public ingress. Development contact login remains
enabled: keep these environments private.

Argo owns Kubernetes workloads; Terraform owns emulated AWS resources. Do not
run Helm upgrades against the adopted emulator releases. Historical Helm
release records may remain in the namespaces, but no Helm controller runs.
The emulator charts own their namespaces with Argo prune/deletion protection;
OMS database and mock-service PVCs retain the base's prune/deletion protection.

## Develop Terraform

From a checkout of this repository, in separate terminals, start the API
forwarder for the environment being used:

```bash
./ops/localstack/port-forward.sh       # http://127.0.0.1:4566
./ops/aws-emulator/port-forward.sh     # https://127.0.0.1:9297
```

Then choose one environment:

```bash
./ops/locdoc-lab/lab.py terraform localstack init
./ops/locdoc-lab/lab.py terraform localstack plan
./ops/locdoc-lab/lab.py terraform localstack apply

./ops/locdoc-lab/lab.py terraform aws-emulator init
./ops/locdoc-lab/lab.py terraform aws-emulator plan -parallelism=1
./ops/locdoc-lab/lab.py terraform aws-emulator apply -parallelism=1
```

Edit `terraform/modules/locdoc-oms-aws` to develop resources once and exercise
both roots under `terraform/environments/locdoc/`. The shared application module defines:

- The OMS document bucket, public-access block, versioning and AES256 encryption.
- Secrets Manager metadata for `oms/precisely/system`, matching the application.
  Secret values are intentionally not stored in Git or supplied by this module.

The bucket names are `locdoc-oms-localstack-documents` and
`locdoc-oms-aws-emulator-documents`; each OMS overlay points at its own bucket.
These names and Terraform states are separate from the earlier generic starter
examples in `ops/localstack/terraform` and `ops/aws-emulator/terraform`.

Each root pins AWS provider **6.20.0** for emulator compatibility and uses local,
Git-ignored state. Keep that state while iterating. Do not use these roots or
states to deploy into AWS. The separate AWS root calls the same modules with an account allowlist and
a separate S3 backend; it does not launch an ECS service by default. See
[the Terraform runbook](../../terraform/README.md) for module boundaries,
capability coverage, offline tests and AWS prerequisites.
The helper isolates the workstation AWS profile; AWS Emulator credentials and
its CA are retrieved without printing or persisting credentials locally.

## Validate the application integration

After a Terraform apply, run the bounded synthetic smoke test:

```bash
./ops/locdoc-lab/lab.py smoke localstack
./ops/locdoc-lab/lab.py smoke aws-emulator
```

It uses the running application's AWS client factories, writes/reads/heads and
removes a unique synthetic object version, describes the integration secret,
checks health and dev login, verifies private object access and rejects
anonymous/other-provider reads. It is restricted to the two lab namespaces,
bucket allowlist and development configuration. It prints no credentials or
session cookies. This is an explicit live test; offline CI does not run it.

## Open OMS

```bash
./ops/locdoc-lab/lab.py forward localstack
# Open http://127.0.0.1:8081

./ops/locdoc-lab/lab.py forward aws-emulator
# Open http://127.0.0.1:8082
```

Choose Support Account or a synthetic contact. The application has the same
synthetic provider IDs in each environment, but its databases and object stores
are separate. Uploaded documents are served through the authenticated,
provider-prefix-scoped `/api/mock-objects/` route, rather than public S3 URLs.

Mail is captured in each namespace's `oms-mailpit` service; use an explicit
namespace port-forward to port 8025 if needed. The payment and supplier services
are simulations. Namespace egress is restricted to local services and CoreDNS,
so these OMS copies cannot call public payment, supplier, tax or AWS endpoints.
The `Demo` setting disables the real Precisely tax call.

## Bootstrap and recover an emulator session

These steps are operator actions, not Argo hooks. Routine GitOps syncs do not
rerun database seeding or apply Terraform, and no cluster writer credential is
committed to Git.

For a fresh lab, prepare its independently managed Kubernetes credentials:

```bash
./ops/locdoc-lab/lab.py prepare localstack
./ops/locdoc-lab/lab.py prepare aws-emulator
```

`prepare` creates `oms-secrets` only when absent and never replaces existing
PostgreSQL or signing secrets. Keep those secrets with their PVCs. It creates or
refreshes `oms-aws-session`, using dummy credentials for LocalStack and the
current generated credentials plus CA for AWS Emulator. Values stay out of tool
output and Git.

After Argo has created each lab database, initialize the empty database once:

```bash
./ops/locdoc-lab/lab.py seed localstack
./ops/locdoc-lab/lab.py seed aws-emulator
```

The named initialization Job runs the existing image's PostgreSQL migrations,
number triggers and guarded synthetic seed in a writable temporary work area
as an unprivileged user. The helper retains a completed Job and refuses to
replace a failed one automatically. It also applies the repository's guarded
mock email/payment/supplier and workflow fixtures. Do not use it against a
production database. It is restricted to these two namespaces.

Emulator resources are **in memory** and can disappear when an emulator
restarts, even though the OMS database and its stored document references
survive. After a restart, run Terraform plan/apply again and reload synthetic
objects. For AWS Emulator, also run `prepare aws-emulator` to refresh the copied
session. Kubernetes projects the updated Secret into OMS; the SDK's short-lived
credential-process result and the TLS adapter reload it without editing a
GitOps Deployment. Allow projected Secret propagation before retrying an upload.

AWS Emulator uses a self-signed certificate for loopback, not its Kubernetes
Service DNS name. A loopback-only sidecar forwards OMS's signed requests to the
private Service with hostname and CA verification for `127.0.0.1`. It preserves
request signatures, never disables authentication, does not log headers or
payloads, and bounds request/response bodies to 64 MiB. The adapter is a lab
integration, not a production gateway.

These emulators do not prove production IAM enforcement, networking, managed
compute, backups, failover or Cognito behavior. The labs retain development
login and local PostgreSQL; S3 and Secrets Manager are the AWS dependencies
used by OMS in these labs. The roots also exercise shared IAM, log-group and
network-topology APIs without changing the Kubernetes application network or
database. NAT, managed compute and AWS database resources are tested as mocked
plans only. Run targeted AWS validation before release.

## Source and image maintenance

`environments/locdoc/base` composes the existing `ops/locdoc` manifests and removes
its MinIO resources. The two overlays supply endpoints and the AWS TLS adapter.
Dependencies are pinned to the images already running in the original lab.
The current application release is recorded in `RELEASE.json`: a clean remote
OMS commit, the successful BuildKit TaskRun, and the verified Linux/amd64 image
digest. It uses `Dockerfile.production` and lockfile installs from
[the application change](https://github.com/Daniel-Maloney/LocDoc_OMS3/pull/78).
The original `locdoc` namespace and historical initialization Job image retain
the earlier image; this release updates only the two emulator-backed OMS apps.
The new runtime image deliberately has no migration/seed toolchain. The old
bootstrap image is retained only for previously initialized lab resources;
provisioning a fresh latest-schema lab needs a separate migration-tool release,
not running synthetic seeds in the production runtime.

For an emulator update, change its chart image digest through a reviewed GitOps
change and repeat the recovery steps above. Removing an Argo application is not
a database backup. Deleting namespaces, PVCs, secrets or emulated resources needs
an explicit data-disposition decision; none is part of normal development.

## Verified database TLS

Each lab owns a separate cert-manager CA, issuer and PostgreSQL server
certificate. OMS mounts only the public CA certificate. PostgreSQL mounts its
private server key read-only as root-owned/group-readable mode 0440 for its
existing GID 999; no root init container or CA private key is given to OMS.
`pg_hba.conf` allows password-authenticated TLS network connections and rejects
plaintext. Local socket access remains available for the existing operator
helpers. The fixture readiness init container uses the pinned PostgreSQL CLI
with CA/hostname verification; it no longer needs tools inside the app image.

```bash
./ops/locdoc-lab/lab.py database-smoke localstack
./ops/locdoc-lab/lab.py database-smoke aws-emulator
```

The test checks the running session's `pg_stat_ssl`, rejects the image's RDS CA
against the private lab certificate, rejects the Service IP's hostname mismatch,
and confirms the server rejects a plaintext connection. It reconnects with the
correct settings after the negative checks. It performs read-only SQL queries.

Server certificates renew 15 days before their 90-day expiry; the lab CA renews
30 days before its annual expiry. Projected Secrets update files, but PostgreSQL
needs an operator-authorized `pg_reload_conf()` after a server certificate
renewal, or a reviewed GitOps rollout. Monitor Certificate readiness/expiry;
this change does not install an automatic restart/reload controller. For a CA
rotation, maintain overlapping trust and validate it before retiring the old
CA. These private certificates do not test RDS's trust chain or rotation.

## Rebuild a release

The existing `remote-buildkit` Task is used without the public-only clone Task.
`build-image.py` verifies a clean worktree and exact remote branch SHA, archives
that commit, verifies the archive checksum in a dedicated staging Pod, then
starts the existing Task against a PVC on the dedicated build node. It passes
the exact source SHA and timestamp as build arguments; no Git credentials enter
the cluster. Default mode is a server-side dry-run preview; `--execute` creates
the named resources within an already authorized build task.

```bash
./ops/locdoc-lab/build-image.py /path/to/clean/oms \
  --branch codex/oms-aws-prerequisites --revision FULL_COMMIT_SHA \
  --provider postgres --execute
```

Run names, archive hash and image repository are recorded under ignored
`.runtime/` before mutation. Never replay an uncertain operation; inspect its
TaskRun first. `--attempt` gives a known failed attempt a new identity. Source
PVCs/run records are retained for audit; cleanup needs a scoped disposition.
The first staging attempt for this release bound its local-path PVC to the
wrong node and never executed a build. The successful attempt explicitly placed
both staging and TaskRun on `workload=build`; it is the only PostgreSQL artifact
used by the release. Do not fetch registry-authentication step logs. Verify the
returned manifest/config hashes, OCI source/revision, platform and UID before
pinning the digest through GitOps. SBOM, signing, vulnerability scanning and
cryptographically verified provenance are not supplied by these labels.

The optional disposable local MySQL handshake test uses fixed synthetic
credentials, generated one-day test certificates, the compiled TLS helper and
the pinned MySQL 8.4 fixture image. It removes only its own fixture container
and anonymous data volume after the run:

```bash
./ops/locdoc-lab/mysql-tls-smoke.py /path/to/compiled/oms
```

That validates real MySQL TLS behavior, not RDS provisioning, migrations or
application business queries against a MySQL schema. The two live OMS labs
continue using their existing PostgreSQL databases and synthetic data.

## Acceptance record

[VALIDATION-20261116.json](VALIDATION-20261116.json) binds the successful release
to exact GitOps, source, Pod and image identities. Both labs passed document
reads (including HEAD/range and anonymous/cross-tenant denial), verified database
TLS and three rejection cases, browser login/home rendering without uncaught
errors/API 5xx, and the UID/read-only-root/writable-scratch contract. Both CAs
are independent. The original `locdoc` remained healthy with its prior image.

The focused application tests and TypeScript/MCP builds pass. Two full-suite
AI catalog/generated-document tests also fail unchanged on the upstream
baseline. The application PR's external Snyk check could not run because the
organization exhausted its private-test allowance; this is not a security scan
pass. Real RDS/ECS/ALB/IAM behavior, production migrations/customer sharing and
cryptographically verified image provenance remain separate release work.

The initial observation above predates a subsequent image-hygiene cleanup:
TypeScript had preserved an existing commented test Stripe credential. Source
and release compiler comments were cleaned up, both database variants were
rebuilt, and `RELEASE.json` now pins the replacement artifacts. The credential
owner should revoke the old test key if it is still active; repository/image
history was not purged and no credential was exercised or rotated here.

`verify-image.py TASKRUN --expected-source FULL_SHA --provider postgres` reuses
the maintained operator registry TLS reader. It verifies manifest/config hashes,
platform, UID and source labels, then reads the bounded compiled-code layer to
check the private route exists and no inline Stripe credential remains. The
old artifact is rejected by this check. This is a scoped credential hygiene
check, not a vulnerability scan or signed provenance.
