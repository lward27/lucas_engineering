#!/usr/bin/env bash
set -euo pipefail
task_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if command -v terraform >/dev/null 2>&1; then
  terraform_bin="$(command -v terraform)"
else
  terraform_bin=/home/wardl/.local/share/locdoc-dev-tools/terraform/1.13.5/terraform
fi
if [[ ! -x "$terraform_bin" ]]; then
  echo 'Install Terraform >= 1.6 and < 2.0, then rerun this command.' >&2
  exit 1
fi
exec "$terraform_bin" -chdir="$task_dir/terraform" "$@"
