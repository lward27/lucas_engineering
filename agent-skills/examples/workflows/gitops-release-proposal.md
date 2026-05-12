# GitOps Release Proposal Workflow

This workflow prepares a release PR but does not merge or sync.

## Inputs

- app name
- source repo under `/Users/wardl/Personal/apps`
- image repository
- immutable image digest
- target chart under `charts/<app>`
- target environment

## Steps

1. Run `goal-intake`.
2. Run `repo-analyzer`.
3. Run `change-risk-assessor`.
4. Run `permission-checker` for `hermes-gitops-release`.
5. Run `approval-gate-manager` if the target is live or high risk.
6. Run `github-gitops-release` to prepare chart changes and PR metadata.
7. Render the chart.
8. Return changed paths, risk, rollback metadata, and next approval gate.

## Stop Conditions

- target environment is unknown
- no immutable image digest is available
- rollback digest or previous Git revision is missing for live release
- GitOps path cannot be mapped
- approval is required but absent
