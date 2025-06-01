{{/*
Expand the name of the chart.
*/}}
{{- define "imagepullsecret-library.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "imagepullsecret-library.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "imagepullsecret-library.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "imagepullsecret-library.labels" -}}
helm.sh/chart: {{ include "imagepullsecret-library.chart" . }}
{{ include "imagepullsecret-library.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "imagepullsecret-library.selectorLabels" -}}
app.kubernetes.io/name: {{ include "imagepullsecret-library.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "imagepullsecret-library.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Image pull secret name
*/}}
{{- define "imagepullsecret-library.secretName" -}}
{{- if .Values.imagePullSecret.name }}
{{- .Values.imagePullSecret.name }}
{{- else }}
{{- printf "%s-imagepullsecret" (include "imagepullsecret-library.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Generate Docker config JSON
*/}}
{{- define "imagepullsecret-library.dockerConfigJson" -}}
{{- if and .Values.imagePullSecret.registry .Values.imagePullSecret.username .Values.imagePullSecret.password }}
{{- $auth := printf "%s:%s" .Values.imagePullSecret.username .Values.imagePullSecret.password | b64enc }}
{{- $config := dict "auths" (dict .Values.imagePullSecret.registry (dict "username" .Values.imagePullSecret.username "password" .Values.imagePullSecret.password "auth" $auth)) }}
{{- if .Values.imagePullSecret.email }}
{{- $_ := set (index $config.auths .Values.imagePullSecret.registry) "email" .Values.imagePullSecret.email }}
{{- end }}
{{- $config | toJson | b64enc }}
{{- else }}
{{- fail "imagePullSecret.registry, imagePullSecret.username, and imagePullSecret.password are required" }}
{{- end }}
{{- end }}
