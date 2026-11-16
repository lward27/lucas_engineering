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
./ops/locdoc-lab/lab.py terraform aws-emulator plan
./ops/locdoc-lab/lab.py terraform aws-emulator apply
```

Edit `terraform/modules/locdoc-oms-aws` to develop resources once and exercise
both roots under `terraform/environments/locdoc/`. The module currently defines:

- The OMS document bucket, public-access block, versioning and AES256 encryption.
- Secrets Manager metadata for `oms/precisely/system`, matching the application.
  Secret values are intentionally not stored in Git or supplied by this module.

The bucket names are `locdoc-oms-localstack-documents` and
`locdoc-oms-aws-emulator-documents`; each OMS overlay points at its own bucket.
These names and Terraform states are separate from the earlier generic starter
examples in `ops/localstack/terraform` and `ops/aws-emulator/terraform`.

Each root pins AWS provider **6.20.0** for emulator compatibility and uses local,
Git-ignored state. Keep that state while iterating. Do not use these roots or
states to deploy into AWS. A later AWS root can call the same resource module
with real provider configuration, credentials and a separate state backend.
The helper isolates the workstation AWS profile; AWS Emulator credentials and
its CA are retrieved without printing or persisting credentials locally.

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
covered by this initial module. Run targeted AWS validation before release.

## Source and image maintenance

`environments/locdoc/base` composes the existing `ops/locdoc` manifests and removes
its MinIO resources. The two overlays supply endpoints and the AWS TLS adapter.
Dependencies are pinned to the images already running in the original lab.
The OMS image was built from a local source worktree with additional changes;
its upstream commit alone does not reproduce it. Preserve that image/worktree
until a separate application source release is authorized.

For an emulator update, change its chart image digest through a reviewed GitOps
change and repeat the recovery steps above. Removing an Argo application is not
a database backup. Deleting namespaces, PVCs, secrets or emulated resources needs
an explicit data-disposition decision; none is part of normal development.
