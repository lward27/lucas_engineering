{{- define "sentinel-rbac.name" -}}
{{- default .Chart.Name .Values.sentinel.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "sentinel-rbac.namespace" -}}
{{- default "monitoring-agents" .Values.sentinel.namespace -}}
{{- end -}}

{{- define "sentinel-rbac.labels" -}}
app.kubernetes.io/name: {{ include "sentinel-rbac.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
