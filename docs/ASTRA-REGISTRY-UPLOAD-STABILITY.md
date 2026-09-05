# ASTRA: Preserve registry uploads across GitOps refreshes

Observed 2026-09-05 in `lucas_engineering`, namespace `registry`.
The authoritative change is the existing `docker-registry` Argo Application in
`charts/root-app/templates/docker-registry.yaml`.

## Failure and cause

The first cluster-to-Mac probe executed an uncached Linux/AMD64 build successfully.
Its authenticated registry push failed with a 502 response and then
`blob upload invalid - invalid secret`. At the same time, Argo replaced the
registry Pod after an unrelated cert-manager version commit.

The retained ReplicaSets at 09:25:13, 09:34:15, and 09:40:12 UTC have identical
configuration checksums and different Secret checksums. The pinned upstream
docker-registry chart 3.0.0 generates `haSharedSecret` with `randAlphaNum` when no
literal value is supplied, and includes that randomized template in the Pod's
`checksum/secret`. Two independent local renders reproduced exactly those two
differences. Node memory, disk, and PID pressure conditions were false.

This is a high-confidence cause for this interrupted upload. It does not explain
or restore the previously missing yfinance image manifest.

## Correction and ownership

The Application preserves only these two existing fields:

- Secret `registry/docker-registry-secret`: `/data/haSharedSecret`.
- Deployment `registry/docker-registry`: the Pod template's `checksum/secret`.

`RespectIgnoreDifferences=true` applies that preservation during synchronization,
not only in the displayed diff. Images, configuration, volumes, resources,
authentication gateway, other Secret fields, and all other applications retain
their existing GitOps behavior. No credential is copied into Git or rotated.
See [Argo's documented sync behavior](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#respect-ignore-differences-configs).

On a fresh installation the chart creates an initial random key. Once the resource
exists, Argo preserves it. An intentional signing-key rotation requires an
explicit maintenance procedure: let active uploads finish, replace only that
Secret field through the owner's secret-management process, and perform a
controlled registry rollout. It is not part of this correction.

## Verification and recovery

Helm lint and two-render comparison establish the template behavior. The rendered
Application must pass server dry-run before merge. After merge, require the exact
Argo source revision and both preservation rules, then record the registry Pod UID
and Deployment generation across a hard refresh and a subsequent GitOps commit.
Complete an authenticated build/push and pull the returned immutable digest.

Do not call the registry prerequisite accepted from a healthy Pod alone. The
execution evidence belongs in PHarness's `ASTRA-M02` records. Do not remove the
preservation rules as an ordinary rollback: that reintroduces random rotation and
interrupted uploads. Registry data, PVCs, and image history are not modified by
this correction.
