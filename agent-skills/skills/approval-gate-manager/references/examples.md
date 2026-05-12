# approval-gate-manager Examples

## Live GitOps Update

Expected decision: `approval_required`.

## Read-Only Prometheus Query

Expected decision: `no_approval_required`.

## Delete PVC

Expected decision: `approval_required` with backup evidence, or `forbidden` if no backup exists.
