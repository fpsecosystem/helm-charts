# Application Chart

A multi-purpose PHP application Helm chart supporting Symfony, Laravel, and custom PHP applications using the bjw-s common library and mariadb-library-chart.

## Description

This application chart provides a flexible deployment solution for PHP applications with the following features:

- **Multi-Purpose Configuration**: Supports Symfony, Laravel, and custom PHP applications
- **Dynamic Environment Variables**: ConfigMap and Secret management for any environment variables
- **Database Integration**: Built-in MariaDB support using the mariadb-library-chart
- **Flexible Image Configuration**: Support for different container images and configurations
- **Modern Kubernetes Resources**: Uses bjw-s common library for standardized resource management

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- [MariaDB Operator](https://github.com/mariadb-operator/mariadb-operator) installed in your cluster (if using database features)
- A MariaDB instance managed by the MariaDB Operator (if using database features)

## Installation

### Method 1: From Helm Repository

```bash
helm repo add fps-charts https://fpsecosystem.github.io/helm-charts
helm repo update
helm install my-app fps-charts/application
```

### Method 2: From Source

```bash
git clone https://github.com/fpsecosystem/helm-charts.git
cd helm-charts/examples/application
helm dependency update
helm install my-app .
```

## Configuration

### Application Configuration

The chart supports dynamic environment variables through two main sections:

- `appConfig.configMap`: Non-sensitive environment variables
- `appConfig.secret`: Sensitive environment variables (passwords, keys, etc.)

### Example Configurations

#### Symfony Application

```yaml
# Use values-symfony.yaml or configure manually:
image:
  repository: "symfony/demo"
  tag: "latest"
  pullPolicy: "Always"

appConfig:
  configMap:
    APP_ENV: "prod"
    MAILER_DSN: "null://null"
  secret:
    APP_SECRET: "change-me-in-production"

# Enable database
mariadb-library-chart:
  database:
    enabled: true
    name: "symfony-app"
  user:
    enabled: true
    passwordSecret:
      generate: true
  grant:
    enabled: true
```

#### Laravel Application

```yaml
# Use values-laravel.yaml or configure manually:
image:
  repository: "laravel/laravel"
  tag: "latest"
  pullPolicy: "Always"

appConfig:
  configMap:
    APP_ENV: "production"
    LOG_CHANNEL: "stack"
    CACHE_DRIVER: "redis"
    SESSION_DRIVER: "redis"
    QUEUE_CONNECTION: "redis"
  secret:
    APP_KEY: "base64:your-app-key-here"
    DB_PASSWORD: "secure-database-password"

# Database configuration
mariadb-library-chart:
  database:
    enabled: true
    name: "laravel-app"
  user:
    enabled: true
    passwordSecret:
      generate: true
  grant:
    enabled: true
```

#### Custom PHP Application

```yaml
# Use values-custom-php.yaml or configure manually:
image:
  repository: "my-registry/my-php-app"
  tag: "v1.0.0"
  pullPolicy: "IfNotPresent"

appConfig:
  configMap:
    PHP_ENV: "production"
    LOG_LEVEL: "info"
    CACHE_ENABLED: "true"
  secret:
    API_SECRET: "your-api-secret"
    DB_PASSWORD: "database-password"

# Minimal database setup
mariadb-library-chart:
  database:
    enabled: true
  user:
    enabled: true
    passwordSecret:
      generate: true
  grant:
    enabled: true
```

### Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `"symfony/demo"` |
| `image.tag` | Container image tag | `"latest"` |
| `image.pullPolicy` | Image pull policy | `"Always"` |
| `appConfig.configMap` | Non-sensitive environment variables | `{}` |
| `appConfig.secret` | Sensitive environment variables | `{}` |
| `mariadb-library-chart.*` | MariaDB configuration (see mariadb-library-chart docs) | See values.yaml |

### Environment Variables

Environment variables are automatically injected from both ConfigMap and Secret:

- **ConfigMap variables**: Available as environment variables in the container
- **Secret variables**: Available as environment variables in the container (secured)

You can add any environment variable to these sections and they will be automatically available in your container.

## Example Value Files

The chart includes several example configurations:

- `values-symfony.yaml`: Symfony application configuration
- `values-laravel.yaml`: Laravel application configuration
- `values-custom-php.yaml`: Custom PHP application configuration

## Templates

This chart provides the following Kubernetes resources:

- **ConfigMap**: Non-sensitive application configuration
- **Secret**: Sensitive application configuration
- **Common Resources**: Via bjw-s common library (Deployment, Service, Ingress, etc.)
- **MariaDB Resources**: Database, user, and grants (when enabled)

## Usage Examples

### Quick Start with Symfony

```bash
helm install my-symfony-app . -f values-symfony.yaml
```

### Quick Start with Laravel

```bash
helm install my-laravel-app . -f values-laravel.yaml
```

### Custom Configuration

```bash
# Create your own values file
cat > my-values.yaml << EOF
image:
  repository: "my-app"
  tag: "v1.0.0"

appConfig:
  configMap:
    CUSTOM_VAR: "value"
  secret:
    SECRET_KEY: "secret-value"
EOF

helm install my-app . -f my-values.yaml
```

### Adding Environment Variables

Simply add any environment variable to the appropriate section:

```yaml
appConfig:
  configMap:
    # Add any non-sensitive variables here
    NEW_CONFIG_VAR: "some-value"
    ANOTHER_VAR: "another-value"
  secret:
    # Add any sensitive variables here
    SECRET_KEY: "secret-value"
    API_TOKEN: "secret-token"
```

## Database Integration

The chart includes the mariadb-library-chart as a dependency for database management:

```yaml
mariadb-library-chart:
  database:
    enabled: true
    name: "my-app-db"
    mariaDbRef:
      name: "mariadb-instance"
      namespace: "mariadb-system"

  user:
    enabled: true
    name: "my-app-user"
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

## Advanced Configuration

### Custom Labels and Annotations

```yaml
commonLabels:
  app.kubernetes.io/part-of: "my-application-suite"
  environment: "production"

commonAnnotations:
  monitoring.coreos.com/enabled: "true"
```

### Resource Limits

```yaml
controllers:
  main:
    containers:
      main:
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
```

## Testing

Test the chart with dry-run:

```bash
helm install my-app . --dry-run --debug
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
