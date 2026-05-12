# Skill Roadmap

Date: 2026-05-10

## Implemented Now

| Skill | Purpose |
| --- | --- |
| `permission-checker` | Registry/tool-grant decisions |
| `approval-gate-manager` | Human gate classification |
| `change-risk-assessor` | Blast-radius and rollback classification |
| `goal-intake` | Delivery brief from user prompt |
| `requirements-clarifier` | Assumptions and blocking questions |
| `spec-writer` | Implementation-ready specs |
| `task-decomposer` | Agent task breakdown |
| `architecture-reviewer` | Platform-fit review |
| `repo-analyzer` | App repo and GitOps mapping |
| `github-gitops-release` | GitOps PR proposal workflow |
| `argocd-health-check` | Read-only Argo/Kubernetes health |
| `prometheus-query-runner` | Bounded PromQL checks |
| `grafana-dashboard-reader` | Dashboard evidence |
| `tempo-trace-analyzer` | Trace evidence |
| `mimir-metrics-analyzer` | Baseline metric comparison |
| `otel-signal-reviewer` | Telemetry completeness |
| `deployment-observer` | Combined post-deploy observation |

## Remaining Phase 1 Stubs

| Skill | Next work |
| --- | --- |
| `code-reviewer` | Add file/line review rubric and examples |

## Phase 2 Candidates

- `test-runner`
- `tekton-build-trigger`
- `container-build-monitor`
- `registry-publisher`
- `pipeline-debugger`
- `argocd-sync`
- `deployment-rollback`
- `post-deployment-report-writer`
- `secrets-access-reviewer`
- `sbom-and-signing-verifier`

## Validation

Run:

```bash
ruby agent-skills/scripts/validate-foundation.rb
ruby agent-skills/scripts/mvp-readiness.rb
```

## Read-Only MVP Helpers

| Helper | Purpose |
| --- | --- |
| `agent-skills/skills/argocd-health-check/scripts/argocd-health-check.rb` | Read Argo CD Application and namespace pod health through Kubernetes |
| `agent-skills/skills/prometheus-query-runner/scripts/prometheus-query.rb` | Run bounded Prometheus/Mimir HTTP API queries |
| `agent-skills/scripts/mvp-readiness.rb` | Check local readiness before enabling the MVP chart |
