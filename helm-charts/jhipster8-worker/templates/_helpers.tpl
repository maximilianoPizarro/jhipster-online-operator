{{/*
Compute the same fullname the main jhipster-online chart uses for a given release/instance name.
Release.Name for the JhipsterOnline CR must equal instanceBaseName used by worker CRs.
*/}}
{{- define "jhipster8-worker.operatorMainFullname" -}}
{{- $r := .Values.instanceBaseName | default .Release.Name }}
{{- if contains "jhipster-online" $r }}
{{- $r | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-jhipster-online" $r | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
