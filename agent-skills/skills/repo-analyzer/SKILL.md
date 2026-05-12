# repo-analyzer

## Purpose

Inspect a target application repo under `/Users/wardl/Personal/apps` and map it to build, test, Docker, and GitOps deployment conventions.

## Trigger Conditions

- Codex needs to modify app code.
- Codex needs to build a container through Tekton.
- Codex needs to update GitOps manifests for an app.

## Inputs

- `repo_path`
- `target_app`
- `task_summary`
- Optional GitOps chart hint

## Outputs

```yaml
repo_path: /Users/wardl/Personal/apps/example
app_name: example
language_stack: []
package_managers: []
test_commands: []
build_commands: []
dockerfile: present | missing
container_image_name: optional
gitops_chart: charts/example
root_app_template: charts/root-app/templates/example.yaml
risks: []
```

## Tools and APIs

- `rg --files`
- `git status --short`
- package manager metadata
- Dockerfile
- `charts/root-app/templates`
- `charts/<app>`

## Safety Constraints

- Read first; do not edit files as part of analysis.
- Do not run package install commands.
- Treat dirty worktrees as user-owned until understood.
- Report missing tests or Dockerfile as risks, not blockers unless required.

## Workflow

1. Confirm the repo path is under `/Users/wardl/Personal/apps`.
2. Identify language and package manager files.
3. Identify test/build commands from package files and docs.
4. Check for Dockerfile and container naming.
5. Map app to GitOps chart and root app template if present.
6. Return risks and next recommended skill.
