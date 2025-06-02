# Installation and Usage Guide

This guide provides detailed instructions on how to use the MariaDB Library Chart in your projects.

## Prerequisites

Before using this library chart, ensure you have:

1. **Kubernetes cluster** (1.19+)
2. **Helm** (3.2.0+)
3. **MariaDB Operator** installed in your cluster
4. **MariaDB instance** managed by the operator

## Installing Prerequisites

### 1. Install MariaDB Operator

```bash
# Add the MariaDB Operator Helm repository
helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
helm repo update

# Install the operator
helm install mariadb-operator mariadb-operator/mariadb-operator \
  --namespace mariadb-system \
  --create-namespace
```

### 2. Create a MariaDB Instance

```yaml
# mariadb-instance.yaml
apiVersion: k8s.mariadb.com/v1alpha1
kind: MariaDB
metadata:
  name: mariadb-instance
  namespace: mariadb-system
spec:
  rootPasswordSecretKeyRef:
    name: mariadb-root-password
    key: password

  database: mysql
  username: mariadb
  passwordSecretKeyRef:
    name: mariadb-password
    key: password

  image: mariadb:11.1.2

  storage:
    size: 10Gi
    storageClassName: standard

  service:
    type: ClusterIP

  replicas: 1
```

Apply it:
```bash
# Create secrets first
kubectl create secret generic mariadb-root-password \
  --from-literal=password="your-root-password" \
  -n mariadb-system

kubectl create secret generic mariadb-password \
  --from-literal=password="your-user-password" \
  -n mariadb-system

# Apply the MariaDB instance
kubectl apply -f mariadb-instance.yaml
```

## Using the Library Chart

### Method 1: As a Helm Repository Dependency

1. **Add the chart repository** (replace with your actual repository URL):

```bash
helm repo add fps-charts https://fpsecosystem.github.io/helm-charts
helm repo update
```

2. **Add dependency to your Chart.yaml**:

```yaml
# your-app/Chart.yaml
apiVersion: v2
name: your-app
description: Your application
type: application
version: 0.1.0

dependencies:
  - name: mariadb-library-chart
    version: "0.1.0"
    repository: "https://fpsecosystem.github.io/helm-charts"
```

3. **Configure values** in your `values.yaml`:

```yaml
# your-app/values.yaml
mariadb-library-chart:
  database:
    enabled: true
    name: "your-app-db"
    mariaDbRef:
      name: "mariadb-instance"
      namespace: "mariadb-system"

  user:
    enabled: true
    name: "your-app-user"
    passwordSecret:
      generate: true
      passwordLength: 24

  grant:
    enabled: true
    privileges:
      - "SELECT"
      - "INSERT"
      - "UPDATE"
      - "DELETE"
```

4. **Create template** to include the library resources:

```yaml
# your-app/templates/mariadb.yaml
{{- $libValues := index .Values "mariadb-library-chart" -}}
{{- $context := dict "Values" $libValues "Chart" .Chart "Release" .Release -}}

{{- if $libValues.database.enabled }}
{{ include "mariadb-library.database" $context }}
{{- end }}

{{- if $libValues.user.enabled }}
{{- if $libValues.user.passwordSecret.generate }}
---
{{ include "mariadb-library.secret" $context }}
{{- end }}
---
{{ include "mariadb-library.user" $context }}
{{- end }}

{{- if $libValues.grant.enabled }}
---
{{ include "mariadb-library.grant" $context }}
{{- end }}
```

5. **Install your application**:

```bash
# Update dependencies
helm dependency update your-app/

# Install the chart
helm install your-app your-app/ \
  --namespace your-namespace \
  --create-namespace
```

### Method 2: As a Git Submodule

1. **Add as submodule**:

```bash
git submodule add https://github.com/fpsecosystem/helm-charts.git charts/helm-charts
```

2. **Reference in Chart.yaml**:

```yaml
dependencies:
  - name: mariadb-library-chart
    version: "0.1.0"
    repository: "file://charts/helm-charts/mariadb-library-chart"
```

## Configuration Examples

### Basic Database and User

```yaml
mariadb-library-chart:
  database:
    enabled: true
    name: "myapp-db"

  user:
    enabled: true
    name: "myapp-user"
    passwordSecret:
      generate: true

  grant:
    enabled: true
```

### Multiple Databases

To create multiple databases, you can use the library chart multiple times with different configurations:

```yaml
# values.yaml
database1:
  enabled: true
  name: "app-db"
  # ... other config

database2:
  enabled: true
  name: "cache-db"
  # ... other config
```

```yaml
# templates/databases.yaml
{{ include "mariadb-library.database" (dict "Values" .Values.database1 "Chart" .Chart "Release" .Release) }}
---
{{ include "mariadb-library.database" (dict "Values" .Values.database2 "Chart" .Chart "Release" .Release) }}
```

### Using Existing Secrets

```yaml
mariadb-library-chart:
  user:
    enabled: true
    name: "existing-user"
    passwordSecret:
      name: "my-existing-secret"
      key: "database-password"
      generate: false
```

### Custom Privileges

```yaml
mariadb-library-chart:
  grant:
    enabled: true
    privileges:
      - "SELECT"
      - "INSERT"
      - "UPDATE"
    table: "specific_table"
```

## Troubleshooting

### Common Issues

1. **MariaDB Operator not found**:
   ```bash
   # Check if operator is running
   kubectl get pods -n mariadb-system
