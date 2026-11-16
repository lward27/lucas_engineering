# LocDoc OMS infrastructure

Shared modules support two private homelab emulators and a separate, greenfield
AWS environment targeting **ECS/Fargate**. The existing Elastic Beanstalk/RDS
installation is not imported or changed. Nothing here migrates production data.

Terraform **1.13.5** is the tested CLI; roots pin AWS provider **6.20.0** for
emulator compatibility. Provider upgrades should be tested against both labs.

| Root | Provider and state | Purpose |
| --- | --- | --- |
| `environments/locdoc/localstack` | Loopback HTTP, dummy credentials, local state | Shared S3, secret metadata, EC2 topology, IAM and log API integration |
| `environments/locdoc/aws-emulator` | Loopback HTTPS, session credentials and verified CA, local state | Same shared API resources, independently isolated OMS |
| `environments/locdoc/aws` | Real AWS, explicit account allowlist, S3 backend | Full AWS foundation; service launch disabled by default |
| `environments/locdoc/state-bootstrap` | Real AWS, explicit account allowlist, local state | Create the protected state bucket once |
| `tests` | Mock AWS provider, plan commands | Credential-free assertions for every module and AWS composition |

## Module boundaries

| Module | Resources / responsibility |
| --- | --- |
| `locdoc-oms-aws` | Versioned private documents bucket, encryption, optional TLS policy, integration secret metadata |
| `locdoc-network` | VPC, two or three AZs, separate public/application/database subnets, route tables, NAT mode, S3 gateway endpoint, security groups |
| `locdoc-kms` | Rotating customer data key, account delegation and scoped CloudWatch encryption policy |
| `locdoc-iam` | Separate ECS application and execution roles, resource-scoped documents/integration secrets and startup permissions |
| `locdoc-registry` | Immutable scanned ECR repository; expire only untagged images |
| `locdoc-database` | Private encrypted Multi-AZ RDS, managed master password, TLS parameter group, backups and deletion protection |
| `locdoc-identity` | Cognito email identity, public browser client, optional TOTP, token revocation and user deletion protection |
| `locdoc-logs` | Encrypted application logs and optional VPC flow logs with bounded retention |
| `locdoc-edge` | Public ALB, HTTP redirect, TLS, ACM/DNS validation, Route53 alias, private IP target group, access logs |
| `locdoc-runtime` | ECS cluster, optional digest-pinned Fargate task/service, injected secrets and database URL bootstrap |
| `locdoc-monitoring` | Unhealthy targets, target 5xx, RDS space, and optional ECS CPU/memory alarms |
| `locdoc-state` | Versioned private TLS-only state bucket, encryption and Terraform deletion protection |

There are no SQS/DynamoDB/Lambda resources: current OMS source does not use them.
Payment, supplier and tax credentials are Secrets Manager integrations, not
AWS-managed substitutes for those vendors. SMTP is configured in the OMS
provider database; this foundation does not create an SES identity or mailbox.
Existing provider tenants use `oms/stripe/<provider_id>` and
`oms/seclock/<provider_id>`; create their secret metadata/values through a
separate tenant provisioning process. The task has read-only permissions for
these two namespaces and the exact `oms/precisely/system` secret.

## Development and coverage

Start the API port-forward(s), then use the operator helper. Full setup and OMS
browser instructions are in [the lab runbook](../ops/locdoc-lab/README.md).

```bash
./ops/localstack/port-forward.sh
# Separate terminal:
./ops/aws-emulator/port-forward.sh
# Separate terminal:
./ops/locdoc-lab/lab.py terraform localstack init
./ops/locdoc-lab/lab.py terraform localstack plan
./ops/locdoc-lab/lab.py terraform localstack apply
./ops/locdoc-lab/lab.py terraform aws-emulator init
./ops/locdoc-lab/lab.py terraform aws-emulator plan -parallelism=1
./ops/locdoc-lab/lab.py terraform aws-emulator apply -parallelism=1
```

Keep each ignored local state. Neither root reads workstation AWS credentials.
AWS Emulator credentials and its CA are retrieved by the helper. These roots
must never be pointed at AWS. The earlier examples under `ops/*/terraform` have
independent buckets and states.

| Capability | Live labs | Mocked AWS plans | Required AWS verification |
| --- | --- | --- | --- |
| S3 and integration secret metadata | Real emulator API create/read/update; OMS uses each isolated bucket | KMS/private/versioned/TLS configuration | IAM denial, private reads, KMS and recovery behavior |
| IAM roles and log groups | API model creation/readback | Permission scope and role separation | Effective authorization, log delivery |
| VPC/subnets/routes/security groups | Topology only, no NAT/endpoints; security-group rules in LocalStack only | Full NAT/endpoint/SG configuration | Actual traffic, routing, external APIs and DNS |
| RDS, Cognito, ALB/ACM, ECR, ECS/Fargate | Kubernetes PostgreSQL and existing OMS images remain in use | Both DB engines, TLS, immutable image, startup gating, HTTPS and composition | DB TLS/migrations/restore, Cognito mail/MFA, image pull, readiness, sockets and certificate issuance |
| Backups, alarms, encrypted logs/state | Not an emulator durability test | Retention, encryption, protection and alarm configuration | Restore drill, delivery/notifications and state lock contention |

AWS Emulator **1.0.385** omits the default outbound security-group permission
that provider **6.20.0** revokes during creation (`InvalidPermission.NotFound`).
Its root sets `security_groups_enabled = false`; LocalStack and the AWS root
keep security groups enabled. This switch affects API-model resources only;
it does not remove Kubernetes network policies or expose either OMS instance.
LocalStack explicitly qualifies security-group references with its dummy
account ID so they round-trip while preserving existing provider resource
identities. Do not change account-discovery flags on existing provider-6 states
without planning the resulting identity migration. If a local port-forward drops mid-apply,
inspect the resulting state and emulator before retrying; created resources may
need import. Lower concurrency (`-parallelism=1`) is recommended for AWS Emulator.

Neither emulator runs the AWS VPC data plane or the production Fargate task.
A passing mocked plan establishes configuration intent and provider schema
compatibility; it does not establish AWS service behavior or availability of an
RDS version. Lab IAM policies do not prove production IAM enforcement. Emulator
resources are in memory; a restart loses them while OMS PostgreSQL/PVCs survive.

Run offline checks locally or in the LocDoc labs GitHub Actions job:

```bash
./ops/locdoc-lab/check-terraform.sh
# Or point TERRAFORM_BIN at an installed Terraform 1.13.5 binary.
```

This runs format/schema checks, mocked plans and runtime/TLS adapter regression
tests. It has no live AWS plan/apply step and needs no AWS credentials.

## AWS preparation and launch

The AWS root creates chargeable resources when applied, including per-AZ NAT,
Multi-AZ RDS and the ALB even with `service_enabled = false`. No AWS apply is part
of lab development. Use a dedicated AWS account for each environment and review its plan. OMS
currently hardcodes integration-secret names, so sharing an account between
production and staging would collide and share tenant credentials.

1. Choose the actual account, region, AZs, DNS zone, domain and database engine.
   Current production uses MySQL; the labs use PostgreSQL. The example engine
   version is illustrative, not an availability guarantee. Match the engine,
   version, parameter family, supported instance class and Prisma image build.
2. Bootstrap `environments/locdoc/state-bootstrap` once with a globally unique
   bucket name and explicit `account_id`/`region`. Preserve its local state in
   operator-controlled storage. It contains no generated database password.
   Bucket protection intentionally prevents casual destruction.
3. In `environments/locdoc/aws`, copy `terraform.tfvars.example` to
   `terraform.tfvars` and `backend.hcl.example` to `backend.hcl`, replacing the
   placeholders. Both local files are ignored. Authenticate with an approved
   AWS role, then run `terraform init -backend-config=backend.hcl`, `terraform
   plan -out=foundation.tfplan`, inspect it, and apply that saved plan only when
   the account and costs are approved. The provider and backend each check an
   explicit account allowlist. State uses native S3 locking (`use_lockfile`),
   not DynamoDB. Give the operator scoped ListBucket/GetObject/PutObject state
   permissions and GetObject/PutObject/DeleteObject for that key's `.tflock`.
4. RDS generates and rotates the **master** password outside Terraform state.
   Use that secret only for a controlled, VPC-reachable database bootstrap.
   Create a separate least-privileged OMS database user and run the matching
   Prisma migrations/triggers with a dedicated migration identity. This repo
   does not automatically run production migrations or seed synthetic data.
5. Populate the application database secret with JSON `username` and `password`;
   populate the runtime secret with independent strong `token_secret` and
   `refresh_token_secret` values. Use a secret-safe operator process. Terraform
   creates metadata only: it never reads or writes secret versions. The ECS
   execution role injects these fields; the task application role cannot read
   the database/master/JWT secrets from Secrets Manager. Add optional API or
   scheduler credentials using `extra_secret_arns` (environment-name to secret
   ARN or ARN JSON-key selector, encrypted with the stack key or the AWS-managed
   Secrets Manager key); plain `extra_environment` is for nonsecret
   application settings. Do not put secret values in tfvars, plans or Git.
6. Complete the application/image prerequisites below, publish a reproducible
   Linux/amd64 release to this environment's ECR repository, verify its digest,
   then set `image_digest` and `service_enabled = true`. The disabled default
   creates neither a task definition with a placeholder image nor a service.
7. Verify Cognito registration/login/MFA and transactional mail, authenticated
   uploads/downloads and tenant isolation, external integrations, database TLS,
   logs, alarm delivery, migrations, backups/restore and graceful shutdown in a
   real AWS nonproduction account before approving a production cutover.

Secret updates require a new ECS deployment to refresh injected values. RDS
master rotation does not rotate the separately provisioned application user.
Plan a separate user-rotation process. Do not supply a master credential as the
application secret. Existing resources/data need an explicit import and
migration design before using this root for an existing production account.

### Application/image prerequisites

- Production upload code currently constructs public S3 URLs. Implement signed
  or authenticated private downloads, including tenant authorization. Keep the
  bucket private; lab `/api/mock-objects/` routing is a development integration.
- The MySQL adapter currently omits TLS options. Wire verified RDS TLS into that
  adapter before selecting MySQL for a running service. PostgreSQL bootstrap
  uses `sslmode=verify-full` and an RDS CA bundle at
  `/etc/ssl/certs/rds-ca.pem`; bake and maintain that bundle in the release image.
- Build the Prisma client for the chosen database. The current lab image came
  from a modified worktree and is not a reproducible production release.
- Provide owned writable bind-mount directories for UID/GID `1000:1000` at
  `/app/uploads`, `/app/dist/logs` and `/tmp` in the image, using matching Docker
  `VOLUME` directives and ownership. Fargate empty mounts otherwise default to
  root ownership; see [AWS bind-mount guidance](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/bind-mount-examples.html).
  These are ephemeral scratch directories; documents must live in S3.
- Emit operational logs to stdout/stderr so `awslogs` receives them; file-only
  Winston logs on ephemeral storage are insufficient. Preserve `/api/health` on
  port 8080 and build the SPA into the same image. Supply public browser build
  configuration (maps, Stripe publishable keys, licensed UI dependencies) at
  build time; runtime ECS variables do not rewrite Vite bundles.
- OMS Socket.IO rooms and background state are in memory. Desired count is one;
  deployment percentages 0/100 avoid overlapping tasks and cause brief downtime.
  Add shared session/socket state and safe singleton job coordination before
  horizontal scaling or zero-downtime rolling releases. The ALB keeps cookie
  affinity and a 600-second idle timeout for current socket behavior.
- Configure provider SMTP and real vendor credentials; development contact
  login and payment/supplier/maps mocks are forced off in this root. Cognito's
  default mail delivery is suitable only for initial testing; add verified
  production email delivery and request quotas before customer use.
- Configure `alarm_action_arns` with approved notification targets. Empty
  defaults create visible CloudWatch alarms without paging anyone. This is a
  foundation, not an on-call/DR/WAF/audit/compliance certification.

Runtime launch stays an explicit operator decision after these prerequisites.
Terraform does not configure vendor accounts, rotate application passwords, build
images, migrate production data or prove application readiness by itself.
