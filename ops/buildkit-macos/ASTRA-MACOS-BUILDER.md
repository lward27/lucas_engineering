# ASTRA: Temporary M1 Mac BuildKit host

The owner selected this M1 Mac on 2026-09-05 while `192.168.50.145` was powered off.
The desktop returned later that day. The active GitOps endpoint now selects the
desktop; this document retains the Mac fallback and its historical evidence.
See [desktop restoration](../../docs/ASTRA-DESKTOP-BUILDKIT-RETURN.md).
This fallback is for `lucas_engineering` only. It does not change
the retired Talos environment or introduce another PHarness coding backend.

## Mac fallback path

Tekton's existing `remote-buildkit` Task connects to the existing Service
`k3s-buildkit.tekton-pipelines.svc.cluster.local:12340`. To select the fallback,
change its EndpointSlice through GitOps to the verified Mac VPN address,
previously `192.168.2.2:12340`. An SSH local forward through Rancher
Desktop's existing Lima connection reaches VM loopback `127.0.0.1:12344`, where
Docker publishes the dedicated BuildKit container's TLS port.

BuildKit TLS remains end to end. The existing server name is
`buildkit-k3s.lucas.internal`; the existing K3s CA, server leaf, and Tekton client
credential are reused. No TLS verification is disabled and no credentials are
placed in Git. Changing the host does not require credential reprovisioning.

The daemon image is the pinned native ARM64 BuildKit v0.26.2 manifest in
`start-rancher-desktop.sh`. It runs inside Rancher Desktop's VM with two CPUs,
2 GiB memory, one parallel build, and its own bounded cache volume. Unlike the
Ubuntu desktop's rootless daemon, this temporary container is privileged inside
the VM. It mounts only its configuration, the existing three K3s TLS files,
the private registry CA, and its cache. It does not mount the Docker socket or a
general Mac source directory.
Build contexts arrive through BuildKit's authenticated session.

The worker advertises ARM64. Actual uncached `linux/amd64` execution has been
verified explicitly, both through Rancher Desktop's named local builder and
through the cluster's TLS client. Never infer AMD64 support from the worker list.

## Start and verify

Run from this GitOps checkout with Rancher Desktop and the VPN active:

These commands alone do not select the Mac for Tekton. Verify the endpoint and
make the reviewed GitOps change after the fallback passes its checks. A failed
desktop connection must not silently select a different builder.

```sh
./ops/buildkit-macos/start-rancher-desktop.sh
./ops/buildkit-macos/forward-rancher-desktop.sh 192.168.2.2
```

The forward stays in the foreground. Keep that process, the Mac, the VPN, and
Rancher Desktop running during builds. The startup script refuses to replace an
existing container; inspect it before restarting or changing its configuration.
The existing Docker context and other builders are left intact.

Verify `buildctl debug workers` from a bounded cluster probe using the existing
Tekton TLS Secret, then build an uncached AMD64 instruction, push it, resolve the
returned manifest digest, and pull/run that exact digest. PHarness's
`ASTRA-M02-MAC-*` evidence records these checks. A smoke Dockerfile proves this
platform path only; it is not M07 source-build acceptance or M11 autonomous work.

The initial public-registry push exposed unrelated GitOps key rotation; see
[the registry correction](../../docs/ASTRA-REGISTRY-UPLOAD-STABILITY.md). The later
PHarness runner build exposed Cloudflare's large-upload limit. The current Mac
BuildKit container uses the verified private TLS route described below. A 112 MiB
random-layer uncached AMD64 build/push completed at 2026-09-05 10:33:16 UTC within
its 360-second bound. Rancher Desktop pulled and ran the exact published digest
`sha256:355e86491465573b4f9e8c41b56e5b28714e74710b88191e399819040b10a144`
with network disabled, verifying architecture and payload size. PHarness evidence
`ASTRA-M02-MAC-PRIVATE-LARGE-UPLOAD.json` records the Job, revisions and results.

## Restore the desktop

First verify the desktop is running, its existing K3s TLS identity works, and a
bounded AMD64 push succeeds. Let active builds finish. Change only the existing
EndpointSlice address back to `192.168.50.145` in GitOps, merge the reviewed change,
and verify Argo's exact revision and a Service-routed build. Keep the server name,
Task credentials, namespaces, and result contracts unchanged. Stop the Mac
forward and dedicated container only after no build still uses them; cache
deletion is not part of this procedure.

The Mac is a temporary availability dependency. Its use does not satisfy M12's
unattended operation gate until the actual accepted hosting arrangement has been
observed for the required period.

## Private registry writes

A real PHarness Python runner build hit Cloudflare's HTTP 413 upload limit. Small
smoke-image publication did not expose that boundary. The temporary Mac therefore
uses the existing authenticated private TLS gateway at `192.168.20.210:32443`.
GitOps grants only the Mac VPN address `192.168.2.2/32` access to that endpoint,
alongside the existing desktop and in-cluster writers. Credentials remain required.

The BuildKit container resolves the canonical registry hostname to that node and
translates only its own outbound registry TCP/443 connection to the NodePort.
The existing registry CA is mounted read-only; hostname verification remains on.
This does not change Mac DNS, the Rancher Desktop engine, cluster DNS, or another
container's routing. Recheck the VPN address and node endpoint before starting.

The local PHarness release builder is a separate Rancher Desktop engine. Its
large outputs may be exported as OCI archives and uploaded through the existing
private TLS gateway with authenticated bounded chunks (verified NodePort or
port-forward transport). Verify every content
hash, source/revision label, architecture, returned digest, and public digest read.
Archive export can change manifest media types; record the actual published digest.
This is publication of the same built source, not a second source build or a
qualification result. The private BuildKit path is now proven by the large-image
probe above; actual source/build linkage and autonomous application delivery
remain PHarness M07 and M11 gates.
