# Image Pull Secret Library Chart

A Helm library chart for managing Docker registry image pull secrets.

## Description

This library chart provides reusable templates for creating Kubernetes image pull secrets. It's designed to be used as a dependency in other Helm charts to easily manage Docker registry authentication.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installation

This is a library chart and cannot be installed directly. It should be used as a dependency in other charts.

### Using as a Dependency

Add this chart as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: imagepullsecret-library-chart
    version: "0.1.0"
    repository: "https://fpsecosystem.github.io/helm-charts"
```

Then in your templates, you can use the template like this:

```yaml
# In your chart's templates/imagepullsecret.yaml
{{ include "imagepullsecret-library.secret" . }}
```

## Configuration

The following table lists the configurable parameters and their default values.

### Image Pull Secret Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `imagePullSecret.enabled` | Enable image pull secret creation | `true` |
| `imagePullSecret.name` | Name of the secret (auto-generated if empty) | `""` |
| `imagePullSecret.registry` | Docker registry URL | `registry.example.com` |
| `imagePullSecret.username` | Registry username | `""` |
| `imagePullSecret.password` | Registry password | `""` |
| `imagePullSecret.email` | Email for the registry (optional) | `""` |
| `imagePullSecret.labels` | Additional labels for secret resource | `{}` |
| `imagePullSecret.annotations` | Additional annotations for secret resource | `{}` |

### Common Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `commonLabels` | Labels applied to all resources | `{}` |
| `commonAnnotations` | Annotations applied to all resources | `{}` |

## Usage Examples

### Basic Usage

```yaml
# values.yaml
imagePullSecret:
  enabled: true
  registry: "registry.gitlab.com"
  username: "myuser"
  password: "mytoken"
```

### With Email

```yaml
# values.yaml
imagePullSecret:
  enabled: true
  registry: "docker.io"
  username: "dockerhubuser"
  password: "dockerhubtoken"
  email: "user@example.com"
```

### Custom Secret Name

```yaml
# values.yaml
imagePullSecret:
  enabled: true
  name: "my-custom-registry-secret"
  registry: "ghcr.io"
  username: "githubuser"
  password: "ghp_token"
```

### Multiple Registries

You can use this library chart multiple times in the same parent chart by using different configurations:

```yaml
# templates/registry-secrets.yaml
{{ include "imagepullsecret-library.secret" (dict "Values" .Values.dockerHub "Chart" .Chart "Release" .Release) }}
---
{{ include "imagepullsecret-library.secret" (dict "Values" .Values.gitlab "Chart" .Chart "Release" .Release) }}
```

## Templates

This library chart provides the following template:

- `secret.yaml` - Creates a Kubernetes image pull secret

## Helper Functions

The chart includes several helper functions in `_helpers.tpl`:

- `imagepullsecret-library.name` - Chart name
- `imagepullsecret-library.fullname` - Full application name
- `imagepullsecret-library.labels` - Common labels
- `imagepullsecret-library.secretName` - Secret name (with fallback)
- `imagepullsecret-library.dockerConfigJson` - Generate Docker config JSON

## Security Considerations

- **Never commit passwords in plain text** to version control
- **Use Kubernetes secrets** or external secret management systems
- **Consider using service accounts** with attached secrets when possible
- **Regularly rotate registry credentials**

## Integration with Deployments

Once the secret is created, you can reference it in your deployments:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      imagePullSecrets:
        - name: {{ include "imagepullsecret-library.secretName" . }}
      containers:
        - name: app
          image: registry.example.com/my-app:latest
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## License

This chart is licensed under the MIT License.

## Support

For support and questions, please open an issue in the [GitHub repository](https://github.com/fpsecosystem/helm-charts).
