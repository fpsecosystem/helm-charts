{{/*
Expand the name of the chart.
*/}}
{{- define "application.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "application.fullname" -}}
{{- $root := . }}
{{- if (get $root.Values "fullnameOverride") }}
{{- $root.Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default $root.Chart.Name $root.Values.nameOverride }}
{{- if contains $name $root.Release.Name }}
{{- $root.Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $root.Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "application.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "application.labels" -}}
helm.sh/chart: {{ include "application.chart" . }}
{{ include "application.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "application.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate Symfony DATABASE_URL from database configuration
This creates a complete DATABASE_URL that Symfony can use
Format: mysql://username:password@host:port/database?serverVersion=X&charset=Y
The serverVersion will be dynamically detected from MariaDB operator during Helm install/update,
otherwise falls back to the configured value.
*/}}
{{- define "application.databaseUrl" -}}
{{- $dbConfig := .Values.database -}}
{{- $username := printf "%s-user" (include "application.fullname" .) -}}
{{- $database := printf "%s-db" (include "application.fullname" .) -}}
{{- $host := include "application.mariadbHost" . -}}
{{- $port := include "application.mariadbPort" . | toString -}}
{{- $charset := $dbConfig.options.charset -}}
{{- $serverVersion := include "application.mariadbVersion" . -}}
{{- printf "mysql://%s:${DATABASE_PASSWORD}@%s:%s/%s?serverVersion=%s&charset=%s" $username $host $port $database $serverVersion $charset -}}
{{- end }}

{{/*
Detect MariaDB version from operator using Helm lookup function
This queries the Kubernetes API during template rendering to get the version
*/}}
{{- define "application.mariadbVersion" -}}
{{- $dbConfig := .Values.database -}}
{{- $mariadbRef := $dbConfig.mariaDbRef -}}
{{- $namespace := $mariadbRef.namespace | default .Release.Namespace -}}
{{- $resourceName := $mariadbRef.name -}}
{{- $fallbackVersion := ($dbConfig.options).serverVersion | default "10.11.0-MariaDB" -}}

{{- /* Try to lookup MariaDB resource from operator */ -}}
{{- $mariadbResource := lookup "k8s.mariadb.com/v1alpha1" "MariaDB" $namespace $resourceName -}}

{{- if $mariadbResource -}}
  {{- /* Try different version fields from the MariaDB resource */ -}}
  {{- $version := "" -}}

  {{- /* Try status.currentVersion first */ -}}
  {{- if and $mariadbResource.status $mariadbResource.status.currentVersion -}}
    {{- $version = $mariadbResource.status.currentVersion -}}
  {{- else if and $mariadbResource.spec $mariadbResource.spec.version -}}
    {{- $version = $mariadbResource.spec.version -}}
  {{- else if and $mariadbResource.spec $mariadbResource.spec.image -}}
    {{- /* Extract version from image tag */ -}}
    {{- $image := $mariadbResource.spec.image -}}
    {{- if contains ":" $image -}}
      {{- $version = (split ":" $image)._1 -}}
    {{- end -}}
  {{- else if and $mariadbResource.metadata $mariadbResource.metadata.labels -}}
    {{- $version = index $mariadbResource.metadata.labels "app.kubernetes.io/version" -}}
  {{- end -}}

  {{- /* Return detected version or fallback */ -}}
  {{- if $version -}}
    {{- $version -}}
  {{- else -}}
    {{- $fallbackVersion -}}
  {{- end -}}
{{- else -}}
  {{- /* No MariaDB resource found, use fallback */ -}}
  {{- $fallbackVersion -}}
{{- end -}}
{{- end }}

{{/*
Detect MariaDB host from operator using Helm lookup function
This queries the Kubernetes API during template rendering to get the host
*/}}
{{- define "application.mariadbHost" -}}
{{- $dbConfig := .Values.database -}}
{{- $mariadbRef := $dbConfig.mariaDbRef -}}
{{- $namespace := $mariadbRef.namespace | default .Release.Namespace -}}
{{- $resourceName := $mariadbRef.name -}}
{{- $defaultHost := printf "%s.%s.svc.cluster.local" $resourceName $namespace -}}
{{- $fallbackHost := ($dbConfig.server).host | default $defaultHost -}}

{{- /* Try to lookup MariaDB resource from operator */ -}}
{{- $mariadbResource := lookup "k8s.mariadb.com/v1alpha1" "MariaDB" $namespace $resourceName -}}

{{- if $mariadbResource -}}
  {{- /* Try different host fields from the MariaDB resource */ -}}
  {{- $host := "" -}}

  {{- /* Try status.connection.host first */ -}}
  {{- if and $mariadbResource.status $mariadbResource.status.connection $mariadbResource.status.connection.host -}}
    {{- $host = $mariadbResource.status.connection.host -}}
  {{- else if and $mariadbResource.status $mariadbResource.status.service $mariadbResource.status.service.name -}}
    {{- /* Construct service name from status */ -}}
    {{- $serviceName := $mariadbResource.status.service.name -}}
    {{- $host = printf "%s.%s.svc.cluster.local" $serviceName $namespace -}}
  {{- else if and $mariadbResource.metadata $mariadbResource.metadata.name -}}
    {{- /* Default service name pattern: mariadb-name */ -}}
    {{- $serviceName := printf "%s" $mariadbResource.metadata.name -}}
    {{- $host = printf "%s.%s.svc.cluster.local" $serviceName $namespace -}}
  {{- end -}}

  {{- /* Return detected host or fallback */ -}}
  {{- if $host -}}
    {{- $host -}}
  {{- else -}}
    {{- $fallbackHost -}}
  {{- end -}}
{{- else -}}
  {{- /* No MariaDB resource found, use fallback */ -}}
  {{- $fallbackHost -}}
{{- end -}}
{{- end }}

{{/*
Detect MariaDB port from operator using Helm lookup function
This queries the Kubernetes API during template rendering to get the port
*/}}
{{- define "application.mariadbPort" -}}
{{- $dbConfig := .Values.database -}}
{{- $mariadbRef := $dbConfig.mariaDbRef -}}
{{- $namespace := $mariadbRef.namespace | default .Release.Namespace -}}
{{- $resourceName := $mariadbRef.name -}}
{{- $fallbackPort := ($dbConfig.server).port | default 3306 -}}

{{- /* Try to lookup MariaDB resource from operator */ -}}
{{- $mariadbResource := lookup "k8s.mariadb.com/v1alpha1" "MariaDB" $namespace $resourceName -}}

{{- if $mariadbResource -}}
  {{- /* Try different port fields from the MariaDB resource */ -}}
  {{- $port := 0 -}}

  {{- /* Try status.connection.port first */ -}}
  {{- if and $mariadbResource.status $mariadbResource.status.connection $mariadbResource.status.connection.port -}}
    {{- $port = $mariadbResource.status.connection.port -}}
  {{- else if and $mariadbResource.spec $mariadbResource.spec.port -}}
    {{- $port = $mariadbResource.spec.port -}}
  {{- else if and $mariadbResource.spec $mariadbResource.spec.service $mariadbResource.spec.service.port -}}
    {{- $port = $mariadbResource.spec.service.port -}}
  {{- end -}}

  {{- /* Return detected port or fallback */ -}}
  {{- if and $port (ne $port 0) -}}
    {{- $port -}}
  {{- else -}}
    {{- $fallbackPort -}}
  {{- end -}}
{{- else -}}
  {{- /* No MariaDB resource found, use fallback */ -}}
  {{- $fallbackPort -}}
{{- end -}}
{{- end }}

{{/*
Database password secret name
*/}}
{{- define "application.databasePasswordSecretName" -}}
{{- include "application.fullname" . }}-password
{{- end }}

{{/*
Database password secret key
*/}}
{{- define "application.databasePasswordSecretKey" -}}
{{- "password" }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "application.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "application.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate MariaDB library chart context
*/}}
{{- define "application.mariadbContext" -}}
{{- $libValues := index .Values "mariadb-library-chart" -}}
{{- dict "Values" $libValues "Chart" .Chart "Release" .Release "Capabilities" .Capabilities "Template" .Template -}}
{{- end }}

{{/*
Generate ingress host using release name as subdomain and domain from staging-domain secret
Note: This generates a placeholder that should be processed by an external controller
or you can manually specify the domain in values.yaml
*/}}
{{- define "application.dynamicIngressHost" -}}
{{- if .Values.ingress.main.dynamicDomain }}
{{- printf "%s.%s" .Release.Name .Values.ingress.main.dynamicDomain -}}
{{- else }}
{{- printf "%s.example.com" .Release.Name -}}
{{- end }}
{{- end }}
