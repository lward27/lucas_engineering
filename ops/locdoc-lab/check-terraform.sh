#!/usr/bin/env bash
# Offline schema and mocked-plan checks. Does not plan/apply against an AWS account.
set -euo pipefail
cd "$(dirname "$0")/../.."
TF_BIN="${TERRAFORM_BIN:-terraform}"
"$TF_BIN" fmt -check -recursive terraform
for root in localstack aws-emulator aws state-bootstrap; do
  "$TF_BIN" -chdir="terraform/environments/locdoc/$root" init -backend=false -input=false -lockfile=readonly
  "$TF_BIN" -chdir="terraform/environments/locdoc/$root" validate
 done
"$TF_BIN" -chdir=terraform/tests init -backend=false -input=false -lockfile=readonly
"$TF_BIN" -chdir=terraform/tests test
node --test ops/locdoc-lab/tests/bootstrap.test.cjs
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s ops/locdoc-lab/tests -v
