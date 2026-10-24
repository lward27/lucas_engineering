# Traefik ingress

Date: 2026-10-24 (LUC-5)

Traefik replaced the retired ingress-nginx controller for every public route on `lucas_engineering`. Kubernetes stopped shipping security fixes for ingress-nginx in March 2026.

## Ownership

- Argo Application `traefik` renders `charts/traefik`, a wrapper over the upstream `traefik/traefik` chart. The image is pinned by digest. Upgrade the chart dependency and the `image.tag` digest together.
- The release runs in namespace `traefik` with two replicas spread across the two untainted nodes and a PodDisruptionBudget.
- The application owns the `traefik.io` and `hub.traefik.io` CRDs (applied server-side) and the default `traefik` IngressClass.
- K3s still ships its bundled Traefik (`kube-system/traefik`, v3.6.7, Deployment scaled to 0). That release originally created the same CRDs and IngressClass, and Argo has since adopted them. Leave the bundled Deployment at 0 replicas.

## Traffic path

```text
Cloudflare -> cloudflared (tunnel, remotely managed config)
  -> ingress-nginx-controller.ingress-nginx.svc:80 (ExternalName alias)
  -> traefik.traefik.svc:80 -> Ingress backends
LAN proxy -> node:30080 / node:30443 (Traefik NodePorts)
```

The Cloudflare tunnel's public hostnames still point to `http://ingress-nginx-controller.ingress-nginx.svc.cluster.local:80`. To keep that name resolving, `charts/traefik` ships an ExternalName Service by that name. After the tunnel origins are changed to `http://traefik.traefik.svc.cluster.local:80`, remove `templates/ingress-nginx-compat.yaml`.

`tekton-webhooks.lucas.engineering` goes from the tunnel straight to the EventListener and does not pass through Traefik.

## Annotation mapping

| ingress-nginx behavior | Traefik equivalent |
| --- | --- |
| `auth-type: basic` + `auth-secret` (pharness-ui) | `basicAuth` Middleware in `pharness`, reading the same Secret (the htpasswd `auth` key works unchanged) |
| `proxy-body-size: 1m` (tekton webhook Ingress) | `buffering.maxRequestBodyBytes` Middleware `tekton-pipelines/github-webhook-body-limit` |
| `proxy-body-size: 0/32m/50m` (registry, datalog, blog) | Not needed. Traefik sets no request body limit; Cloudflare still caps uploads |
| `proxy-read-timeout`/`proxy-send-timeout` 300 to 3600 s | Not needed. Traefik sets no backend response timeout; entry point `readTimeout=0` keeps WebSocket and long uploads open |
| `proxy-buffering: off` (SSE, WebSocket) | Not needed. Traefik streams responses and proxies WebSocket upgrades natively |
| `use-forwarded-headers`, `proxy-real-ip-cidr` | `forwardedHeaders.trustedIPs`: pod CIDR `10.42.0.0/16` (tunnel) and node subnet `192.168.20.0/24` |
| Epheros server snippet, `allow-snippet-annotations` | Dropped. Epheros is retired |

Other behavior to know:

- `strictPrefixMatching` keeps Kubernetes `Prefix` semantics, so `/api` does not match `/apix`.
- Only `pharness` and `tekton-pipelines` may attach Middlewares through Ingress annotations (`crossProviderNamespaces`). Add a namespace there before using `traefik.ingress.kubernetes.io/router.middlewares` anywhere else.
- Request headers whose names contain anything other than letters, digits, or dashes are dropped (`aliasHeadersStrategy: delete`). This covers nginx's default `underscores_in_headers off`.
- Routes that had no `proxy-body-size` annotation were limited to nginx's 1 MiB default. Under Traefik they have no limit.
- NetworkPolicies that admit ingress traffic select the `traefik` namespace.
- Prometheus scrapes both pods through the `kubernetes-pods` job on port 9100.

## Validation performed

A pilot on the live controller (before cutover) confirmed: basic auth returns 401 with the realm without or with wrong credentials and 200 with valid ones; the 1 MiB limit returns 413; trusted `X-Forwarded-Proto` and `X-Forwarded-For` pass through; strict prefixes hold; a WebSocket stays open past 60 s. After cutover, every public hostname was checked through Cloudflare for status, redirect, and certificate.

## Rollback

Revert the cutover merge commits. That restores `charts/ingress-nginx`, its root-app Application, the `nginx` class on every route, and the NetworkPolicies. Remove the ExternalName alias first, or Argo cannot recreate the `ingress-nginx-controller` Service. The Traefik application can stay deployed during a rollback.

## Follow-ups

- Change the Cloudflare tunnel origins to `traefik.traefik.svc.cluster.local:80`, then remove the ExternalName alias.
- On the next K3s upgrade, add `disable: [traefik]` to the K3s server config so the dormant bundled release is removed. Its Helm uninstall deletes the shared CRDs and IngressClass, so plan a short window and hard-refresh the `traefik` Application immediately to recreate them. Middleware objects are deleted together with their CRD and come back when their applications resync.
