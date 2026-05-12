# code-reviewer

## Purpose

Review code, chart, cluster, and skill changes for correctness, regressions, missing tests, security risks, and operational safety.

This skill is read-only. It produces findings and an approval recommendation; it does not edit the code it reviews.

## Trigger Conditions

- A Hermes coding, GitOps, or planning task produces a diff.
- A PR is ready for automated review.
- A change touches `charts/`, `cluster/`, `agent-skills/`, CI/CD, RBAC, NetworkPolicy, or deployment behavior.

## Inputs

- `diff`
- `changed_paths`
- `spec`
- `test_results`
- `risk_assessment`
- `target_environment`

## Outputs

```yaml
findings:
  - severity: P1 | P2 | P3
    file: path
    line: 1
    issue: short description
    recommendation: short fix
open_questions: []
approval_recommendation: approve | request_changes | block
test_gaps: []
```

## Review Priorities

1. Bugs that break requested behavior.
2. Safety issues, including secrets, RBAC, direct cluster mutation, or destructive behavior.
3. GitOps drift or app-of-apps mistakes.
4. Missing or insufficient tests.
5. Operational risks in rollout, rollback, or observability.

## File-Specific Checks

| Area | Checks |
| --- | --- |
| `charts/` | Helm renders, values are sane, app-of-apps path matches conventions |
| `cluster/` | RBAC least privilege, no secret reads, network policies scoped |
| `agent-skills/` | Skill has purpose, triggers, inputs, outputs, safety constraints |
| `docs/` | Docs match implementation and do not overstate live wiring |
| app repos | Tests, build commands, Dockerfile, runtime config, backwards compatibility |

## Safety Constraints

- Lead with findings.
- Include exact file and line when available.
- Do not approve live deployment changes without evidence of tests, rollback, and observability.
- Do not treat missing tests as acceptable without an explicit reason.
- Do not reveal secrets from diffs; flag and redact.

## Example Invocation

```text
Review this GitOps PR for deploying finance-frontend to apps-prod.
```
