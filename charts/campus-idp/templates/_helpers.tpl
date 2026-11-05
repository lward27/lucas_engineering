{{- define "campus-idp.labels" -}}
app.kubernetes.io/part-of: pharness-campus
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/component: campus-idp
{{- end }}

{{- define "campus-idp.userEnv" -}}
{{- printf "CAMPUS_USER_%s_PASSWORD" (. | upper | replace "-" "_") -}}
{{- end }}
