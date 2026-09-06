# Output Contracts

## Diagnostic Skills

Return a concise verdict with target, time, observed evidence, missing visibility, and the next useful action. Use the following fields when a durable diagnostic artifact is requested; headings are optional and should match the task:

```markdown
# Summary
- Status, context, cluster, environment, namespace, scope, observation window, confidence

# Findings
- Severity, observation, evidence, likely impact, likely cause, confidence, recommended next action

# Proposed Remediation
- Operation class and exact target for each action

# Actions Executed
- Exact target, operation, reason, validation, result

# Missing Visibility
- Signals that could not be obtained

# Commands Executed
- Sanitized, bounded commands only
```

State `none` for actions not executed. Keep observations and inferences distinct.

## Write-Oriented Skills

For a change, lead with the result, its validation, and any remaining gate. Preserve the following information in evidence when relevant; do not force every field into every progress update:

```markdown
# Requested Change
# Target
- Context, namespace, resources
# Operation Classification
# Assumptions
# Repository Conventions Detected
# Plan
# Files Changed
# Rendered Resources
# Validation Results
# Diff or Preview
# Changes Applied
# Security Considerations
# Observability Considerations
# Rollout Verification
# Rollback Procedure
# Destructive Operations
```

State `none` for destructive operations when none occurred. Include the final confirmation text and the resource allowlist when Class C is executed.
