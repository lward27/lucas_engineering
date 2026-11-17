# Loc-Doc LocalStack development environment

Private Helm release `localstack` in namespace `localstack`, context
`lucas_engineering` (`/home/wardl/.kube/config`, API `192.168.20.192:6443`).
The source chart is `charts/localstack`, reconciled by the root Argo CD application
from this repository. For the actual OMS Terraform labs, use
[the shared lab workflow](../locdoc-lab/README.md); the example below is the
earlier standalone API starter.

This starter deliberately uses the legacy Apache-licensed Community **4.12.0**
image, pinned by manifest digest. It needs no LocalStack account or paid token.
It is an older release without ongoing upstream security maintenance. Use only
synthetic development data. Do not replace its image with `latest`: current
LocalStack images have different account, license, and feature requirements.

## Connect from this workstation

In terminal 1, keep the localhost-only tunnel running:

```bash
cd /home/wardl/Personal/lucas_engineering
./ops/localstack/port-forward.sh
```

In terminal 2:

```bash
cd /home/wardl/Personal/lucas_engineering
curl --fail http://127.0.0.1:4566/_localstack/health
./ops/localstack/terraform.sh init
./ops/localstack/terraform.sh plan
./ops/localstack/terraform.sh apply
```

The wrapper uses Terraform on PATH, falling back to the SHA256-verified
Terraform 1.13.5 binary installed under
`/home/wardl/.local/share/locdoc-dev-tools/terraform/1.13.5/terraform`.
The provider lock file records the tested AWS provider version. Terraform's
state is kept in `ops/localstack/terraform/terraform.tfstate`, ignored by Git;
keep that local file while developing. The example provisions
`locdoc-dev-documents`, its public-access-block configuration, and
`locdoc-dev-document-jobs`. It is a separate local-only root, with dummy
credentials, explicit service endpoints, and no AWS remote backend. Reuse
resource modules in a separate AWS root when preparing the real environment.

For AWS CLI or SDK access use these **mock** credentials, not your AWS profile:

```bash
export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1 AWS_EC2_METADATA_DISABLED=true
aws --endpoint-url http://127.0.0.1:4566 s3api list-buckets
aws --endpoint-url http://127.0.0.1:4566 sqs list-queues
```

For SDK S3 clients enable path-style addressing. SQS uses conventional
`/account/queue` URLs, advertised with the private Kubernetes service hostname;
the dynamic `/queue/region/account/name` format is rejected by the tested
Terraform AWS provider. Local SDK/CLI clients must keep the explicit loopback
endpoint override when using these queue URLs. Returned service URLs can name
the private service; a workstation should use its configured port-forward
endpoint rather than blindly following a returned URL.

## Cluster access and isolation

The private service endpoint is
`http://localstack.localstack.svc.cluster.local:4566`. NetworkPolicy admits
client Pods in the **localstack namespace only**, plus Kubernetes-authenticated
port-forward access. There is no Ingress, NodePort, LoadBalancer, host port,
Docker socket, or Kubernetes API token mounted in the application.

For a Terraform client running in that namespace:

```bash
terraform apply \
  -var='localstack_endpoint=http://localstack.localstack.svc.cluster.local:4566'
```

NetworkPolicy allows DNS to CoreDNS and outbound public HTTPS for runtime
dependency downloads; private, loopback, and link-local IPv4 destinations are
excluded from that HTTPS rule. Isolation depends on the cluster's network-policy
enforcement. The namespace enforces Kubernetes restricted Pod Security; the
runtime uses UID/GID 1000 with all Linux capabilities dropped. It requests
250m CPU/512Mi memory and is limited to 2 CPUs/2Gi memory.

## Scope and durability

Enabled API services: S3, SQS, SNS, DynamoDB, IAM, STS, KMS, Secrets Manager,
SSM, EventBridge, Logs, CloudWatch, API Gateway, Step Functions, EC2, Route 53.
An enabled service is not a claim of complete AWS API or behavioral parity.

This setup has **ephemeral emulator state**. Restarting its process or replacing
the Pod can lose resources, objects, queue messages, and test secrets. There is
no PVC or persistence promise. After a reset, run `terraform plan` and
`terraform apply` to recreate tracked resources; upload synthetic fixtures again
as needed. Local Terraform state alone does not preserve emulator data.

IAM policies are not enforced in this Community setup. Provisioning roles and
policies does not validate authorization. Lambda execution, ECS workloads,
RDS instances, and real EC2 virtual machines are outside this starter's scope;
EC2 API metadata emulation is available. Run PostgreSQL and application
containers separately in the homelab. Current Kubernetes-native executors and
durable snapshots require evaluating LocalStack's applicable licensed features.

## Maintain

Inspect the workload without changing the current kubeconfig context:

```bash
kubectl --kubeconfig /home/wardl/.kube/config --context lucas_engineering \
  -n localstack get pods,services,networkpolicies
```

Before an intentional GitOps chart update, review the diff and remember that a Pod
replacement resets the emulator. Validate the chart locally using:

```bash
helm lint charts/localstack
helm template localstack charts/localstack -n localstack
```

No existing application resources are modified by this installation. Removing
the Helm release would stop this environment and discard its emulated data;
removing the namespace also removes any additional resources placed there.

For an idle starter queue only, rerun the S3/SQS smoke test with:

```bash
kubectl --kubeconfig /home/wardl/.kube/config --context lucas_engineering \
  -n localstack exec -i deployment/localstack -- python - < ops/localstack/smoke.py
```

This creates and removes a uniquely named synthetic object and message. Do not
run it against a queue with application producers or consumers.

References: [legacy image source and license](https://github.com/localstack/localstack/tree/v4.12.0),
[Terraform integration](https://docs.localstack.cloud/aws/connecting/infrastructure-as-code/terraform/),
[current Kubernetes executor requirements](https://docs.localstack.cloud/aws/customization/kubernetes/).
