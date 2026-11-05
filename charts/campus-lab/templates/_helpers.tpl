{{- define "campus-lab.labels" -}}
app.kubernetes.io/part-of: pharness-campus
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/component: campus-lab
{{- end }}

{{- define "campus-lab.slotName" -}}
{{- printf "%s%d" .root.Values.slots.namePrefix .index -}}
{{- end }}

{{/*
Guardrails every slot namespace carries. Call with
dict "root" $ "namespace" <name>.
*/}}
{{- define "campus-lab.slotGuardrails" -}}
{{- $root := .root -}}
{{- $ns := .namespace -}}
{{- $quota := $root.Values.slots.quota -}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
automountServiceAccountToken: false
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: campus-lab-slot
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
spec:
  hard:
    pods: {{ $quota.pods | quote }}
    count/jobs.batch: {{ $quota.jobs | quote }}
    count/cronjobs.batch: "0"
    count/deployments.apps: "0"
    count/statefulsets.apps: "0"
    count/daemonsets.apps: "0"
    count/replicasets.apps: "0"
    replicationcontrollers: "0"
    requests.cpu: {{ $quota.cpu | quote }}
    limits.cpu: {{ $quota.cpu | quote }}
    requests.memory: {{ $quota.memory | quote }}
    limits.memory: {{ $quota.memory | quote }}
    requests.ephemeral-storage: {{ $quota.ephemeralStorage | quote }}
    limits.ephemeral-storage: {{ $quota.ephemeralStorage | quote }}
    requests.storage: "0"
    persistentvolumeclaims: "0"
    services: "0"
    services.loadbalancers: "0"
    services.nodeports: "0"
    secrets: {{ $quota.secrets | quote }}
    configmaps: {{ $quota.configMaps | quote }}
---
apiVersion: v1
kind: LimitRange
metadata:
  name: campus-lab-slot
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
spec:
  limits:
    # Pod-level maximum only: a Container maximum would also default missing
    # limits, which must instead be rejected by the session guard.
    - type: Pod
      max:
        cpu: {{ $quota.cpu | quote }}
        memory: {{ $quota.memory | quote }}
        ephemeral-storage: {{ $quota.ephemeralStorage | quote }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: campus-lab-default-deny
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
---
# The broker listener is the only part of the control plane a session can
# reach (LUC-131). Pinned ClusterIP, no DNS: the policy sees the post-DNAT
# Pod address, so it names the broker Pods and their broker port only.
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: campus-lab-session-broker
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ $root.Values.broker.namespace }}
          podSelector:
            matchLabels:
              {{- toYaml $root.Values.broker.podLabels | nindent 14 }}
      ports:
        - protocol: TCP
          port: {{ $root.Values.broker.port }}
{{- if $root.Values.egress.enabled }}
---
# Sessions whose effective policy approves egress carry the egress label
# (set by the provider, checked by the session guard) and may reach the
# egress proxy port; the proxy decides everything else per connection.
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: campus-lab-session-egress
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      {{ $root.Values.egress.podLabel.key }}: {{ $root.Values.egress.podLabel.value | quote }}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ $root.Values.egress.namespace }}
          podSelector:
            matchLabels:
              app: {{ $root.Values.egress.name }}
      ports:
        - protocol: TCP
          port: {{ $root.Values.egress.port }}
---
# The proxy identifies the session behind a connection by its Pod address.
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $root.Values.egress.name }}
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $root.Values.egress.name }}
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ $root.Values.egress.name }}
subjects:
  - kind: ServiceAccount
    name: {{ $root.Values.egress.name }}
    namespace: {{ $root.Values.egress.namespace }}
{{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pharness-campus-controller
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
rules:
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["create", "get", "list", "watch", "delete"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch", "delete"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "get", "list", "delete"]
  # The occupancy's broker token: created, replaced on rotation and deleted
  # with the workload. No watch and no patch; the secret guard admits only
  # Opaque token Secrets with the session's ownership labels.
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["create", "get", "list", "update", "delete"]
  # Read-only: the provider refuses to launch when an isolation policy is
  # missing or weakened, and can never change one.
  - apiGroups: ["networking.k8s.io"]
    resources: ["networkpolicies"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pharness-campus-controller
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pharness-campus-controller
subjects:
  - kind: ServiceAccount
    name: {{ $root.Values.controller.serviceAccount.name }}
    namespace: {{ $root.Values.controller.serviceAccount.namespace }}
---
# Browser terminals: find the session Pod and exec into it, nothing else. The
# API selects the Pod by its occupancy labels and only after authorizing the
# browser session against the lab journal. Exec over WebSocket needs create
# on pods/exec from Kubernetes 1.31 (get before), so both are granted.
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pharness-campus-terminal
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["get", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pharness-campus-terminal
  namespace: {{ $ns }}
  labels:
    {{- include "campus-lab.labels" $root | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pharness-campus-terminal
subjects:
  - kind: ServiceAccount
    name: {{ $root.Values.terminal.serviceAccount.name }}
    namespace: {{ $root.Values.terminal.serviceAccount.namespace }}
{{- end }}
