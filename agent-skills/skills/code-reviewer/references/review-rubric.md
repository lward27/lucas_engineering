# Code Reviewer Rubric

## Severity

| Severity | Meaning |
| --- | --- |
| P1 | Must fix before merge; likely outage, security issue, data loss, or broken core behavior. |
| P2 | Should fix before merge; meaningful bug, missing gate, unsafe operational behavior, or important test gap. |
| P3 | Nice to fix; maintainability, clarity, or small risk. |

## Approval Recommendation

- `approve`: no blocking findings and test evidence is acceptable.
- `request_changes`: at least one P2 or unresolved test gap.
- `block`: P1 finding, secret exposure, destructive risk, or missing approval gate for live change.
