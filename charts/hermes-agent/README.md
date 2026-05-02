# Hermes Agent

Standalone Hermes Agent deployment. This chart is intentionally separate from
OpenClaw: it uses its own namespace, PVC, secrets, ingress host, and runtime
state.

## Required manual secrets

Create provider/platform secrets outside Git:

```sh
kubectl create namespace hermes-agent --dry-run=client -o yaml | kubectl apply -f -

kubectl -n hermes-agent create secret generic hermes-api-keys \
  --from-literal=FIREWORKS_API_KEY='...' \
  --from-literal=GH_TOKEN='...' \
  --from-literal=TELEGRAM_BOT_TOKEN='...'
```

Use a Telegram bot token that is not used by OpenClaw if both agents should run
at the same time.

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

The dashboard can store API keys. If it is exposed publicly, protect it before
adding the Cloudflare route.

## Enable the app

After secrets exist, set `apps.hermes-agent.enabled=true` in
`charts/root-app/values.yaml` and let Argo CD sync the new application.
