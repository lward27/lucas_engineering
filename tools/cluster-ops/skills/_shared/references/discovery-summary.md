# Discovery Summary

Discovery ran on 2026-07-10 using read-only kubeconfig, API, workload, CRD, namespace, and storage-class queries. No live mutation ran. Secret values were not requested or displayed.

## Context Mapping

| Intended cluster | Resolved context | Dedicated kubeconfig | Live result |
| --- | --- | --- | --- |
| lucas-engineering | `lucas_engineering` | `~/.kube/config` | reachable |
| lucas-engineering-2 | `lucas-engineering-v2` | `~/.kube/config-lucas-engineering-v2` | reachable |
| mlselscls-k3s | `default` | `~/.kube/mlselscls-k3s.yaml` | API timeout |

## lucas-engineering

- Kubernetes `v1.34.4+k3s1`; two Ready nodes; local-path is the default storage class.
- Argo CD is present in `argocd` with Application, ApplicationSet, and AppProject CRDs.
- Tekton Pipelines, Triggers, Dashboard, and Resolvers are present in `tekton-pipelines` and `tekton-pipelines-resolvers`.
- Grafana, Loki, Mimir, Tempo, Prometheus, and an OpenTelemetry Collector are present in `monitoring`.
- cert-manager, metrics-server, ingress-nginx, Traefik, an in-cluster docker-registry, and Gateway API CRDs are present.
- Cilium and Hubble were not discovered. The active CNI is therefore unknown from this pass. MinIO was not discovered.

## lucas-engineering-2

- Kubernetes `v1.35.5+k3s1`; one Ready node; local-path is the default storage class.
- Flux is present in `flux-system`; Flux source, Kustomize, Helm, and image automation CRDs are installed.
- Cilium, Cilium Envoy, Cilium Operator, Hubble Relay, and Hubble UI are present in `kube-system`.
- Grafana, Loki, Mimir, Tempo, Prometheus, and an OpenTelemetry Collector are present in `monitoring`.
- metrics-server, an in-cluster docker-registry, and Gateway API CRDs are present. Argo CD, Tekton, cert-manager, and MinIO were not discovered.

## mlselscls-k3s

- The dedicated kubeconfig and context mapping were discovered locally.
- The API did not respond before the bounded request timeout. Version, nodes, components, storage classes, ingress, registry, and observability remain unknown.

## Local Tooling

- Available: `kubectl`, `helm`, `cilium`, and `jq`.
- Unavailable during discovery: `argocd`, `tkn`, `hubble`, `yq`, `shellcheck`, `kubeconform`, and `conftest`.

## Repository Signals

- `lucas_engineering` is an Argo CD-oriented Helm repository with local charts for observability, Tekton, registry, and agent workloads.
- `lucas-engineering-v2` is Flux-managed and uses Kustomize plus HelmRelease resources.
- Standard Kubernetes application labels are common. No global application, environment, ownership, or Tekton label contract was inferred beyond the profile.
