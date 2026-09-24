# ASTRA: In-cluster Tekton BuildKit target

Status: proposed. The GitOps chart is the source of truth; this route is not
active until its PR is merged and Argo CD reports the resulting
`tekton-ci` revision as `Synced` and `Healthy`.

The `remote-buildkit` Task retains its Tekton inputs and image URL/digest results.
Its `k3s-buildkit` ClusterIP Service now selects a single rootless BuildKit
Deployment on the dedicated AMD64 node labeled `workload=build` and tainted
`workload=build:NoSchedule`. The daemon image is pinned to the official
`moby/buildkit:v0.33.0-rootless` multi-platform image digest. The node must remain
Ready with that label and taint; the chart does not alter node configuration.

## Isolation and credentials

- The daemon runs as UID 1000, has no host path, host network, Kubernetes API
  token, or privileged container setting. Rootless BuildKit requires an
  unconfined seccomp/AppArmor profile and privilege escalation for its user-
  namespace helpers; BuildKit's OCI worker also uses `noProcessSandbox` in this
  containerized rootless mode. These are documented residual risks, not a
  claim that builds are a hard isolation boundary from the daemon.
- cert-manager creates a private CA plus distinct server-only and client-only
  certificates. The client certificate and registry push credential are
  mounted only into the Tekton build Task and are never stored in Git. The
  registry auth provider forwards only the needed credentials to BuildKit over
  the mTLS session; credentials are not mounted into the daemon. The trigger
  service account can read only the named GitHub webhook Secret, not the
  BuildKit CA or registry credential.
- The BuildKit NetworkPolicy accepts TCP/12340 only from Pods carrying
  `tekton.dev/task=remote-buildkit`. Egress allows CoreDNS, the registry write
  gateway on TCP/8443, and public TCP/80 and TCP/443, while excluding private,
  loopback, link-local and cluster address ranges. No direct write to the
  public Cloudflare route is used; Tekton results keep the canonical public
  registry URL. Public web egress is not domain-restricted, so trusted source
  and build-file review remains necessary to prevent external exfiltration.
- The daemon cache is a 60 GiB `local-path` PVC, provisioned on the builder node
  by `WaitForFirstConsumer`. The BuildKit worker limits its cache to 45 GB and
  retains 5 GB of free-space headroom. It is disposable build cache, not an
  application data volume.

## Certificate maintenance

The server certificate is valid for five years and cert-manager renews it one
year before expiry. BuildKit loads the gRPC server keypair at process start; it
does not pick up a renewed projected Secret automatically. After
`k3s-buildkit-server` renews, wait until no remote-buildkit TaskRun is active,
then restart the daemon Deployment so it loads the renewed certificate. Keep
the old certificate valid during that window. The client Secret is projected
for each new TaskRun and can rotate independently. Rotate the CA only as a
planned maintenance operation, reissue both leaf certificates, and restart the
daemon after active builds finish.

## Acceptance checks

After merge and Argo reconciliation, verify all of the following before using
this target for a PHarness release build:

1. `tekton-ci` is `Synced`/`Healthy`; the `k3s-buildkit` Service has one ready
   endpoint, and its Pod is on `ubuntu-lucas-engineering-build`.
2. The Pod reports an AMD64 rootless worker and stays ready under its resource
   limits. Confirm its PVC is bound to the same node.
3. A bounded uncached `linux/amd64` smoke build connects with mTLS, reaches the
   private write gateway, pushes a test image, and returns a valid SHA-256
   digest. Pull and run that exact digest with networking disabled; do not
   change any workload image pin during this smoke check.
4. A PHarness release PipelineRun uses the exact merged source SHA and the
   existing immutable build-only Pipeline and `tekton-ci-build` no-token
   service account. Verify the registry digest and OCI
   source/revision labels. Leave deployment, promotion, Test Diagnosis, and
   model execution gates unchanged.

If acceptance fails, retain the run and evidence. Do not silently restore the
Mac endpoint: it is currently unreachable. Any alternate builder requires its
own observed readiness and reviewed GitOps route.
