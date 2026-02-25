# Architecture

- Homelab Kubernetes cluster
  - Kubernetes running in a k3s
- ArgoCD deployed in argocd namespace
- Root app manages:
    - platform services
    - microservices
    - databases

- Microservices are deployed via Helm charts stored in their own repos.