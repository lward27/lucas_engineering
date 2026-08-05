{{- define "epheros.image" -}}
{{- if .digest }}{{ .repository }}@{{ .digest }}{{ else }}{{ .repository }}:dev{{ end }}
{{- end }}
{{- define "epheros.labels" -}}
app.kubernetes.io/name: epheros
app.kubernetes.io/part-of: epheros
app.kubernetes.io/managed-by: argocd
{{- end }}

