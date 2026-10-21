# Scheduled cluster maintenance

The [lucas_engineering cluster maintenance Linear project](https://linear.app/lucas-engineering/project/lucas-engineering-cluster-maintenance-026cce2f7470) is the work board for the `lucas_engineering` k3s cluster. The weekly Sol planner creates and updates issues there. Four Luna workers pick up issues for security, Helm charts, Kubernetes, and general maintenance. This directory retains the standing policy and issue template. The old Markdown tickets are archived locally for reference and are no longer a queue. Keep the computer and ChatGPT desktop app running during scheduled hours.

## Ticket contract

Create each ticket as one issue in the Linear project, using [TEMPLATE.md](TEMPLATE.md) for its description. Use exactly one category label: `maintenance:security`, `maintenance:helm`, `maintenance:kubernetes`, or `maintenance:general`. Linear status and labels are authoritative: `Todo` means queued and actionable, `In Progress` means claimed, `In Progress` plus `maintenance:review` means awaiting review, `Backlog` plus `maintenance:blocked` means blocked, and `Done` means complete. Do not create a duplicate for an unfinished issue; update the existing issue with fresh evidence. The planner creates at most eight new issues per week and at most two per category. Workers take the highest-priority `Todo` issue in their category, one issue per run. Record timestamps in America/New_York. After a human resolves a blocker or approves an exact action, record the approval reference and scope in the issue, remove the blocker/review label, and return it to `Todo` if worker action remains.

Every issue must identify the exact target and current version, a verified candidate version or maintenance action, sources and release notes, likely impact, validation, rollback, and whether an approval gate applies. If any of these are unknown, the worker may investigate but must not deploy. Never put credentials, Secret values, kubeconfigs, or workload environment data in issues or run output. If Linear is unavailable, report the failed access and stop queue work; do not silently resume the archived file queue.

## Standing change policy

The user's standing authorization covers the following routine work on the named `lucas_engineering` context only:

- Read-only, bounded inspection of cluster and GitOps state; research of upstream releases and security advisories; Linear issue creation and updates.
- Isolated source edits, tests, chart rendering, and a pull request for one scoped ticket.
- Merge and GitOps deployment of a **low-risk patch update** to one existing, enabled, non-platform application when all gates below pass. This includes a patch-level upstream Helm chart or application image security fix with no required migration or resource-shape change. A worker must verify the actual upstream release and inspect release notes and the rendered diff before classifying it as low risk.

For an automatic merge and deployment, require: a clean isolated source worktree started from current remote main; current live Argo revision checked; one app per change; no unrelated diff; passing relevant tests, `helm lint` and rendered diff; no CRD, RBAC, NetworkPolicy, Secret reference, ingress, storage, database, or namespace change; backup/rollback evidence appropriate to the target; reviewed PR diff; successful CI if configured; exact commit and image or chart version recorded in Linear; post-sync health observation. Stop on failed checks, drift, unclear ownership, or an unhealthy baseline. Do not approve your own PR as a substitute for these gates. A change outside this policy can still be prepared as an issue or PR, but waits for explicit human approval of its concrete diff and rollout plan before merge or deployment.

**Always require explicit human approval** for Kubernetes/k3s or node upgrades; major or minor version upgrades; core platform components (Argo CD, ingress, CNI, cert-manager, Tekton, registry, observability, storage, databases, and cluster security controls); new or changed CRDs, RBAC, NetworkPolicy, Secrets, or external access; destructive actions, pruning, rollbacks with data impact, and operations involving PVCs or data migrations. No worker may infer approval from an issue's existence, priority, elapsed time, or the planner's recommendation. Record the human approval reference and exact scope in the Linear issue before proceeding.

Follow [the GitOps workflow](../../docs/gitops-workflow.md), [the permissions model](../../docs/permissions-model.md), and [the maintained cluster operator interface](../../docs/operations/ASTRA-CLUSTER-DEVELOPMENT.md). Use the explicit `lucas_engineering` context and profile-selected kubeconfig for every cluster operation. Never switch the current context or directly override an Argo-owned resource. A failed deployment stops further deployments for that run and is reported with evidence; do not improvise a destructive recovery.

## Run order

The planner runs Sunday at 8 PM. Workers run Monday through Friday at 1 AM (`security`), 2 AM (`helm`), 3 AM (`kubernetes`), and 4 AM (`general`), America/New_York. Workers do nothing and stay quiet when their category has no actionable Linear issue. The planner reviews unfinished issues before adding new ones, and prioritizes supported security fixes and existing unhealthy conditions over novelty.
