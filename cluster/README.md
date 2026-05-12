# Agentic Platform Cluster Manifests

This directory contains cluster scaffolding for the agentic SDLC platform.

These raw manifests are review/reference artifacts. The live GitOps path should use the Helm-managed version rather than applying files from this directory directly.

The Helm-managed version lives in `charts/agentic-platform` and is registered in `charts/root-app` with `apps.agentic-platform.enabled: false`.

Initial scope:

- namespaces for agent runtime, CI, GitOps helpers, observability, apps, sandbox, and secrets
- read-only Hermes observer RBAC
- guardrail documentation for no secret reads
- conservative network policy examples for agent runtime and Hermes read-only egress

Do not apply broad default-deny policies to live app namespaces without an app-by-app network test.
