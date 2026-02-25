# Rules

- This repo uses ArgoCD app-of-apps pattern.
- All argocd app definitions live under /charts/root-app/templates/
- No restructuring folders without explicit request.
- Do not convert Helm to Kustomize.
- Do not introduce Terraform unless explicitly requested.
- Do not modify existing cluster-level RBAC.
- Do not modify entrypoint.sh files or k3s startup files.
- You can ssh into lucas_engineering using `ssh lucas_engineering`.
- You can update the caddyfile and reload the caddy server on lucas_engineering vm.