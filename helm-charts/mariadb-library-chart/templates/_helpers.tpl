{{/*
Expand the name of the chart.
*/}}
{{- define "mariadb-library.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mariadb-library.fullname" -}}
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
{{- define "mariadb-library.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mariadb-library.labels" -}}
helm.sh/chart: {{ include "mariadb-library.chart" . }}
{{ include "mariadb-library.selectorLabels" . }}
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
{{- define "mariadb-library.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mariadb-library.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "mariadb-library.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Database name
*/}}
{{- define "mariadb-library.databaseName" -}}
{{- if .Values.database.name }}
{{- .Values.database.name }}
{{- else }}
{{- include "mariadb-library.fullname" . }}-db
{{- end }}
{{- end }}

{{/*
Username
*/}}
{{- define "mariadb-library.username" -}}
{{- if .Values.user.name }}
{{- .Values.user.name }}
{{- else }}
{{- include "mariadb-library.fullname" . }}-user
{{- end }}
{{- end }}

{{/*
Password secret name
*/}}
{{- define "mariadb-library.passwordSecretName" -}}
{{- if .Values.user.passwordSecret.name }}
{{- .Values.user.passwordSecret.name }}
{{- else }}
{{- include "mariadb-library.fullname" . }}-password
{{- end }}
{{- end }}

{{/*
MariaDB reference namespace
*/}}
{{- define "mariadb-library.mariadbNamespace" -}}
{{- if .Values.database.mariaDbRef.namespace }}
{{- .Values.database.mariaDbRef.namespace }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
Generate random password
*/}}
{{- define "mariadb-library.generatePassword" -}}
{{- randAlphaNum .Values.user.passwordSecret.passwordLength }}
{{- end }}
