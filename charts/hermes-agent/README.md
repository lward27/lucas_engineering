# Hermes Agent

Standalone Hermes Agent front door. This chart owns the Hermes namespace,
ingress host, and runtime state for the Hermes-only agent platform.

The default mode is `hermes.runtime.mode=external`: Kubernetes keeps the
cert-manager/nginx ingress path for `https://hermes.lucas.engineering`, while
the actual Hermes process runs on the desktop at `192.168.50.145:9120`.

Set `hermes.runtime.mode=kubernetes` to run Hermes in-cluster as the original
StatefulSet-backed deployment.

## Required manual secrets

Create provider/platform secrets outside Git:

```sh
kubectl create namespace hermes-agent --dry-run=client -o yaml | kubectl apply -f -

kubectl -n hermes-agent create secret generic hermes-api-keys \
  --from-literal=FIREWORKS_API_KEY='...' \
  --from-literal=GH_TOKEN='...' \
  --from-literal=TELEGRAM_BOT_TOKEN='...'
```

Use a Telegram bot token dedicated to Hermes.

LM Studio is configured as the default custom inference provider through its
OpenAI-compatible endpoint at `http://192.168.50.145:1234/v1`, using model
`google/gemma-4-e4b`. It does not require a secret. Keep `FIREWORKS_API_KEY` in
`hermes-api-keys` to continue using the Fireworks provider/models as an option.

Optional cluster and SSH access:

```sh
kubectl -n hermes-agent create secret generic hermes-kubeconfig \
  --from-file=config=/path/to/kubeconfig

kubectl -n hermes-agent create secret generic hermes-ssh \
  --from-file=id_ed25519=/path/to/id_ed25519 \
  --from-file=id_ed25519.pub=/path/to/id_ed25519.pub \
  --from-file=known_hosts=/path/to/known_hosts \
  --from-file=config=/path/to/ssh_config
```

## Public access

The messaging gateway can use Telegram long polling and does not need ingress.
Only enable ingress when exposing the dashboard, API server, or webhooks.

This chart exposes the Hermes Web UI/dashboard on
`https://hermes.lucas.engineering` and embeds the chat UI. The desktop process
also serves authenticated `/api/*` routes from the same `192.168.50.145:9120`
front door. In external mode, the Service has no selector and an EndpointSlice
sends traffic to the desktop reverse proxy.

The dashboard can store API keys. If it is exposed publicly, protect it before
adding the Cloudflare route.

## Enable the app

After secrets exist, set `apps.hermes-agent.enabled=true` in
`charts/root-app/values.yaml` and let Argo CD sync the new application.
