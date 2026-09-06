# Global Operating Model

Treat these inputs as separate sources of truth:

1. Global configuration: the shared profile and safety references define approved contexts, aliases, and durable safeguards.
2. Repository conventions: inspect the active repository, its `AGENTS.md`, charts, Kustomize overlays, GitOps definitions, validation scripts, and ownership model.
3. Live state: query the selected context with bounded, read-only commands before relying on repository intent.
4. User intent: apply only the requested scope and operation class.

Resolve context aliases through `../scripts/context-guard.sh`. State the requested alias, resolved context, selected namespace, repository convention, and operating mode before a mutation. Do not record repository-specific roots, endpoints, credentials, or application details back into this global pack unless they are genuinely shared.

Prefer the local repository's established Helm, Kustomize, raw-manifest, Argo CD, Flux, and Tekton patterns. When no pattern exists, propose the smallest conventional implementation and mark assumptions. A cluster component being present does not authorize creating resources for it.

For `lucas_engineering`, use [the maintained operator interface](ASTRA-LUCAS-OPERATOR-INTERFACE.md). Reuse its verified profile and operation records before writing another task-local client. Read the relevant repository's release procedure only when doing a release. Shared profiles describe expected identities; verify them against the actual API server and selected Argo source.

Keep one current-state record with source revision, active operation IDs, evidence links, authorization boundaries, and the next eligible action. Reconcile existing operations before dispatch. Run one qualification experiment at a time; classify infrastructure, measurement, and model failures separately. Do not change the tested source while its qualification is active.

When the profile or API cannot establish a fact, report it as unknown. Do not fill gaps from names, historic layouts, or provider assumptions.
