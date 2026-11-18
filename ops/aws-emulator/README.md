# AWS Emulator homelab environment

AWS's [AWS Emulator](https://github.com/aws/aws-emulator), version **1.0.385**,
deployed as the Helm release `aws-emulator` in its dedicated **aws-emulator**
namespace on context **lucas_engineering**. This is separate from the existing
LocalStack release and its Terraform state.

## Start tinkering

Keep this running in terminal 1:

```bash
cd /home/wardl/Personal/lucas_engineering
./ops/aws-emulator/port-forward.sh
```

In terminal 2:

```bash
cd /home/wardl/Personal/lucas_engineering
./ops/aws-emulator/client.py aws sts get-caller-identity
./ops/aws-emulator/client.py aws s3api list-buckets
./ops/aws-emulator/client.py aws sqs list-queues
./ops/aws-emulator/client.py aws dynamodb list-tables
```

The endpoint is **https://127.0.0.1:9297**. `client.py` runs the command you
give it with the ready Pod's generated emulator credentials in memory and its
current TLS CA. It checks the health endpoint with certificate validation,
disables host-prefix injection, explicitly sets the endpoint for AWS CLI
commands, and uses an isolated AWS configuration instead
of your workstation's normal AWS profile. It does not print or save the keys.
Only the CA certificate is cached under ignored `.runtime/`. For Node.js it
also supplies `NODE_EXTRA_CA_CERTS`. Java and other SDK-specific trust settings
may need additional setup; see the [AWS SDK guide](https://docs.aws.amazon.com/emulator/latest/userguide/point-sdk-to-emulator.html).

`test`/`test` from LocalStack do **not** authenticate here. The emulator generates
new credentials and a new certificate at every start. Rerunning the helper
loads the current ones. If a Pod is replaced, restart the port-forward as well.

## Terraform starter

```bash
./ops/aws-emulator/terraform.sh init
./ops/aws-emulator/terraform.sh plan
./ops/aws-emulator/terraform.sh apply
```

The wrapper runs Terraform through the same credential/TLS helper. It uses
Terraform on PATH, or the existing locally installed Terraform 1.13.5.
AWS provider 6.20.0 is pinned in the lock file. Later providers (including
6.72.0) read bucket tags through S3 Control, which adds an account-ID hostname
prefix that this emulator cannot receive. This compatibility pin uses the
older S3 tagging API and applies only to this experimental root. See the
[AWS hostname limitations](https://docs.aws.amazon.com/emulator/latest/userguide/point-sdk-to-emulator.html).
The local-only root explicitly
sets service endpoints and permits account `000000000000` only. State lives in
`ops/aws-emulator/terraform/terraform.tfstate` and is ignored by Git. It is
independent of the LocalStack example and any eventual AWS environment.

The example provisions bucket `emulator-dev-documents` with its public-access
block, queue `emulator-dev-document-jobs`, and DynamoDB table
`emulator-dev-documents`. Reusable application modules can later be called by
separate emulator and AWS roots with their own providers and state.

To rerun the S3/SQS/DynamoDB smoke test against the **idle starter only**:

```bash
./ops/aws-emulator/client.py python3 ops/aws-emulator/smoke.py
```

It verifies the emulator account, rejection of wrong credentials, object
upload/download, message send/receive, and item put/get. It removes only the
synthetic fixtures it creates. Do not run it once application clients are
producing or consuming messages on the starter queue.

The workstation's source-packaged AWS CLI 2.31.35 under Python 3.14 has an
argument-help formatting bug affecting `aws sqs send-message` before it sends
a request (`badly formed help string`). The included smoke test uses its
bundled Python SDK directly and works around that CLI parser issue. The CLI
read commands above work. The system AWS CLI installation was not modified.

## Isolation and lifecycle

- ClusterIP service `aws-emulator.aws-emulator.svc.cluster.local:9297`, no public
  ingress, host port, NodePort, LoadBalancer, Docker socket, or API token.
- NetworkPolicy admits only same-namespace clients on TCP 9297 and denies all
  Pod egress. Kubernetes-authenticated port-forward is the supported workstation
  access path. The generated TLS certificate is for local access; the private
  service DNS name is not a verified client TLS endpoint.
- Authentication and HTTPS stay enabled; telemetry is explicitly disabled.
- Restricted Pod Security, UID/GID 1000, read-only root filesystem, all Linux
  capabilities dropped. Requests: 250m CPU, 512Mi RAM, 100Mi temporary storage.
  Limits: 2 CPUs, 2Gi RAM, 512Mi temporary storage.
- Resource data is **in memory**. A process restart, Pod replacement, or OOM
  loses resources and test data. There is no persistent volume. Refresh and
  apply Terraform to recreate resources, then reload synthetic fixtures.
- The emulator has gaps compared with AWS and is intended for development,
  not production or validating security controls. Request signature checks
  are not a claim of AWS IAM-policy parity. See
  [AWS's documentation](https://docs.aws.amazon.com/emulator/latest/userguide/what-is-service.html).

## Image provenance and maintenance

AWS does not publish an official container image. This image follows its
[documented container recipe](https://docs.aws.amazon.com/emulator/latest/userguide/getting-started-docker.html)
using an immutable Amazon Linux 2023 base and the AWS-signed x86_64 RPM:

```text
https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/aws-emulator-1.0.385-1-x86_64.rpm
SHA256: 2b2b5031e559d74c7a4154b11056be3a57716a177cd796cf058eebd91a6870d7
AWS signing key: 98BCF336A3BE53B734E967C52E5BF49BD940F624
Source commit: 813af480bf7f16d5418b64e4f5644a74a7da11c5
```

Before building, download the RPM and `.sig`, import AWS's public key from
`https://downloads.aws.com/keys/gpg/current.asc`, compare its fingerprint with
the one above, and verify the detached signature as described in the
[Linux installation guide](https://docs.aws.amazon.com/emulator/latest/userguide/getting-started-linux.html).
The verified RPM belongs in `image/.artifacts/aws-emulator.rpm` (ignored by Git).
Build from `image/Dockerfile` with Linux AMD64, then export the image as
`image/.artifacts/aws-emulator.tar`. `publish-image.py` publishes that archive
through the existing authenticated internal TLS gateway, keeping the named
registry credentials in memory. `image/IMAGE.json` records the verified digest.
The chart deploys by that immutable digest.

This chart is now reconciled by the root Argo CD application from this repository.
For the actual OMS Terraform labs, use [the shared lab workflow](../locdoc-lab/README.md).
The example above is the earlier standalone API starter. Inspect with:

```bash
kubectl --kubeconfig /home/wardl/.kube/config --context lucas_engineering \
  -n aws-emulator get deployment,pods,services,networkpolicies
```

For an intentional GitOps update, remember it resets the emulator's memory. Validate
the new chart and review its diff:

```bash
helm lint charts/aws-emulator
```

Uninstalling this release or deleting its namespace stops it and loses its
in-memory resources. Neither is needed to disconnect; stopping the local
port-forward leaves the cluster runtime running.
