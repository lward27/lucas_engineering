# Repository Discovery

Before generating or changing manifests, inspect the current working directory and its repository root for:

- `AGENTS.md`, README files, Makefiles, Taskfiles, package scripts, shell scripts, and CI workflows.
- Helm charts and values, Kustomize bases and overlays, raw manifests, and existing validation commands.
- Argo CD Applications, ApplicationSets, AppProjects, Flux Kustomizations and HelmReleases, Tekton resources, monitoring resources, policies, ingress or Gateway definitions, storage, and artifact conventions.

Select the most specific established pattern. Use Helm where the app is chart-managed, Kustomize where the target is an overlay, and raw manifests only where the repository already uses them. Determine GitOps ownership before proposing direct cluster changes. Do not adopt provider-specific infrastructure files as a pattern for this pack.

The current workspace demonstrates two distinct repository-local directions: the `lucas_engineering` repository contains Helm and Argo CD app-of-apps material; `lucas-engineering-v2` contains Flux-managed Kustomize and HelmRelease material. Treat these as local conventions, not defaults for unrelated repositories.
