{{- define "lumos.name" -}}
lumos
{{- end }}

{{- define "lumos.fullname" -}}
{{ include "lumos.name" . }}
{{- end }}
