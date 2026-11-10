# Linear issue: short, specific task title

- Linear status: Todo | In Progress | Backlog | Done
- Category label: maintenance:security | maintenance:helm | maintenance:kubernetes | maintenance:general
- Add maintenance:review or maintenance:blocked when applicable
- Priority: Urgent | High | Medium | Low
- Created: YYYY-MM-DD HH:MM America/New_York
- Updated: YYYY-MM-DD HH:MM America/New_York
- Target: exact chart, application, node, or namespace
- Current state/version: verified value and evidence link or command summary
- Candidate/action: verified value and upstream source
- Approval: delegated-maintenance | human-required | human-approved (include reference, concrete scope and conditions; delegated-maintenance uses the user's 2026-11-10 dev-cluster delegation in README.md)
- Owner: unclaimed | worker name

## Why this matters

Describe the issue, exposure, or maintenance benefit. Link an advisory or upstream release notes when relevant.

## Scope and plan

List the exact files or resources expected to change and the smallest safe sequence.

## Validation and rollback

List preflight, render/diff, tests, backup or rollback revision, and post-deployment observations.

## Work log

Add dated evidence, PR and run links, delegated approval decision and exact scope, result, and any technical blocker. Preserve prior work logs and approval scopes; a new approval does not retroactively authorize a past action. Never include secrets.
