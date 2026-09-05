# ASTRA: Finance immutable build contracts

These are finite Lucas Engineering build paths for the approved PHarness autonomous
SDLC program. They publish images; PHarness owns staging and production promotion.
Production GitOps merge requires its separate, state-bound human approval.

| Pipeline | Fixed repository | Fixed image repository |
| --- | --- | --- |
| `pharness-yfinance-build` | `lward27/yfinance_wrapper` | `registry.lucas.engineering/yfinance_wrapper` |
| `pharness-finance-frontend-build` | `lward27/finance-frontend` | `registry.lucas.engineering/finance-frontend` |

Both run in `tekton-pipelines`, accept the full lowercase 40-character `revision`,
verify the actual checkout, and use the existing `remote-buildkit` Task. They pass
`SOURCE_COMMIT` into the Dockerfile, publish `git-<sha>`, and return `SOURCE_COMMIT`,
`IMAGE_URL`, and `IMAGE_DIGEST`. The application's Dockerfile must retain the source
revision in its OCI label. The controller must independently verify image identity;
a result alone is not supply-chain attestation or deployment evidence.

The owner-authorized Mac serves the existing mutually authenticated BuildKit service.
See [Mac operation](../buildkit-macos/ASTRA-MACOS-BUILDER.md) for its availability and TLS
boundary. Builds target Linux AMD64. TLS verification stays enabled; credentials
remain mounted only in the shared build Task's existing authentication boundary.
No Finance Pipeline contains a deployment or rollout-restart task.

The old frontend push webhook is disabled. Argo removes only its obsolete
`TriggerBinding/finance-frontend-binding` and
`TriggerTemplate/finance-frontend-template`, and the EventListener no longer routes
frontend pushes. The yfinance webhook was already disabled. No application
Deployment or persistent volume is changed by this chart update.

Validate the rendered contracts and execute their actual negative guard scripts:

```sh
python3 ops/finance-delivery/check-build-contracts.py
helm lint charts/tekton-ci
```

The checker needs the existing Helm, Ruby YAML reader, Bash and Python tools. It
performs 32 checks without credentials, builds or cluster writes. It covers invalid
source revisions, mismatched checkouts, malformed digest results, fixed repository
and image bindings, and retirement of the frontend webhook.

Deployment evidence and real build acceptance belong to PHarness's
`planning/evidence/autonomous-sdlc/ASTRA-M07-SOURCE-DELIVERY-AND-BUILDS.md`.
These passing manifest checks do not close M07 or qualify the coding model.
