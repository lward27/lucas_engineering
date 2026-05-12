# change-risk-assessor Examples

## Docs Change

Risk: `low`

Approval: no

## Live Image Digest Update

Risk: `high`

Approval: yes

Required evidence: tests, image digest, GitOps diff, rollback digest, observation plan.

## Secret Value Request

Risk: `critical`

Approval: forbidden for general agents. Route to human break-glass if truly needed.
