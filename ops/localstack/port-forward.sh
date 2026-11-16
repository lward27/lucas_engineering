#!/usr/bin/env bash
set -euo pipefail
exec kubectl --kubeconfig /home/wardl/.kube/config --context lucas_engineering \
  --namespace localstack port-forward --address 127.0.0.1 service/localstack 4566:4566
