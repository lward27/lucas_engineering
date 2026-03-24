{{- define "code-server.serviceAccountName" -}}
{{- if .Values.codeServer.serviceAccount.create -}}
    {{ default .Values.codeServer.name .Values.codeServer.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.codeServer.serviceAccount.name }}
{{- end -}}
{{- end -}}
