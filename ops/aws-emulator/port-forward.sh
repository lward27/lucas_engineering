#!/usr/bin/env bash
set -euo pipefail
exec kubectl --kubeconfig /home/wardl/.kube/config --context lucas_engineering \
  --namespace aws-emulator port-forward --address 127.0.0.1 service/aws-emulator 9297:9297
