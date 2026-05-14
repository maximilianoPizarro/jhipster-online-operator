{{- define "mcp-worker.operatorMainFullname" -}}
{{- $r := .Values.instanceBaseName | default .Release.Name }}
{{- if contains "jhipster-online" $r }}
{{- $r | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-jhipster-online" $r | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
