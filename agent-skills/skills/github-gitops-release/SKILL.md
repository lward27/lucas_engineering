# github-gitops-release

## Purpose

Prepare GitOps manifest changes in the `lucas_engineering` app-of-apps repo and package them as a reviewable branch or pull request.

This skill proposes GitOps releases. It does not merge PRs, sync Argo CD, publish images, or bypass approval gates.

## Trigger Conditions

- A build produced an immutable image digest.
- A new app wrapper chart needs to be added.
- A chart value needs to point at a new image digest.
- Root app wiring needs to add or enable an app.

## Inputs

- `app_name`
- `image_digest`
- `image_repository`
- `chart_path`
- `root_app_template`
- `target_environment`
- `rollback_digest`
- `approval_gate`

## Outputs

```yaml
branch: agentic/gitops-<app>-<short-sha>
changed_paths: []
pull_request: optional link
summary: short release note
approval_required: true
rollback_plan: previous revision or digest
post_merge_next_skill: argocd-health-check
```

## Tools and APIs

- Git
- GitHub API or CLI
- Helm template/render checks
- `permission-checker`
- `change-risk-assessor`
- `approval-gate-manager`

## Required Permissions

Branch and pull-request permission for `lward27/lucas_engineering`. No direct Kubernetes mutation.

## Safety Constraints

- Do not commit raw secrets.
- Do not merge the PR.
- Do not enable live root-app values without approval.
- Prefer image digests over mutable tags.
- Include rollback digest or previous Git revision for live changes.

## Workflow

1. Run `permission-checker` for GitOps write/proposal access.
2. Run `change-risk-assessor`.
3. Confirm required approval gate for live changes.
4. Update the app wrapper chart or root app template.
5. Render the changed chart with Helm.
6. Create a branch and PR if GitHub write access is available.
7. Return changed paths, evidence, approval needs, and rollback metadata.
