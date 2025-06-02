# Universal PHP Application Helm Chart

A universal Helm chart for deploying PHP applications including WordPress, Laravel, Symfony, and other PHP frameworks. This chart provides a flexible foundation that can be customized for any PHP application by simply providing your application image and configuration.

## Features

- **Universal Support**: Works with WordPress, Laravel, Symfony, and any PHP application
- **Flexible Persistence**: Multiple storage options with bjw-s common library patterns
- **Database Integration**: Built-in MariaDB operator support with automatic connection
- **Dynamic Configuration**: ConfigMap-based environment variable management
- **High Availability**: Multi-replica support with shared storage options
- **Security**: Separate handling of sensitive and non-sensitive configuration
- **Modern Patterns**: Uses bjw-s common library for Kubernetes best practices

## Quick Start

### Deploy a WordPress Site

```bash
helm install my-wordpress ./application -f values-wordpress.yaml \
  --set appConfig.configMap.WORDPRESS_DB_PASSWORD="secure_password" \
  --set controllers.main.containers.main.image.repository="wordpress" \
  --set controllers.main.containers.main.image.tag="6.4-apache"
```

### Deploy a Laravel Application

```bash
helm install my-laravel ./application -f values-laravel.yaml \
  --set appConfig.configMap.APP_KEY="base64:your-laravel-key" \
  --set controllers.main.containers.main.image.repository="your-registry/laravel-app" \
  --set controllers.main.containers.main.image.tag="latest"
```

### Deploy a Symfony Application

```bash
helm install my-symfony ./application -f values-symfony.yaml \
  --set appConfig.configMap.APP_SECRET="your-symfony-secret" \
  --set controllers.main.containers.main.image.repository="your-registry/symfony-app" \
  --set controllers.main.containers.main.image.tag="latest"
```

## Configuration

### Application Configuration (`appConfig`)

All application environment variables are managed through the `appConfig.configMap` section:

```yaml
appConfig:
  configMap:
    APP_ENV: "production"
    DATABASE_URL: "mysql://user:pass@host:3306/db"
    # Add any environment variables your application needs
```

**Note**: Sensitive values should be provided via Helm values or external secrets, not hardcoded in values files.

### Persistence Configuration

The chart supports multiple persistence patterns using bjw-s common library:

#### Basic App Data Storage
```yaml
persistence:
  app-data:
    enabled: true
    type: persistentVolumeClaim
    size: 8Gi
    globalMounts:
      - path: /var/www/html/storage  # Laravel
      # - path: /var/www/html/var    # Symfony
      # - path: /var/www/html/wp-content  # WordPress
```

#### Multi-Replica Shared Storage
```yaml
persistence:
  shared:
    enabled: true
    type: persistentVolumeClaim
    size: 10Gi
    accessMode: ReadWriteMany  # Required for sharing between pods
    globalMounts:
      - path: /var/www/html/public/uploads
```

#### Performance Cache Storage
```yaml
persistence:
  cache:
    enabled: true
    type: emptyDir
    medium: Memory
    sizeLimit: 1Gi
    globalMounts:
      - path: /tmp/cache
```

### Database Integration

The chart includes built-in MariaDB operator integration:

```yaml
database:
  mariaDbRef:
    name: "my-mariadb"      # Name of MariaDB custom resource
    namespace: "database"   # Namespace where MariaDB is deployed
  options:
    charset: "utf8mb4"
    serverVersion: "10.11.0-MariaDB"
```

The chart automatically:
- Detects the MariaDB service and credentials
- Generates appropriate `DATABASE_URL` environment variable
- Configures connection parameters

### Ingress Configuration

```yaml
ingress:
  main:
    enabled: true
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    hosts:
    - host: "myapp.example.com"
      paths:
      - path: /
        pathType: Prefix
        service:
          name: main
          port: http
    tls:
    - secretName: myapp-tls
      hosts:
      - myapp.example.com
```

## Framework-Specific Examples

### WordPress

WordPress requires specific environment variables and persistence configuration:

```yaml
# values-wordpress.yaml
appConfig:
  configMap:
    WORDPRESS_DB_HOST: "mariadb"
    WORDPRESS_DB_NAME: "wordpress_db"
    WORDPRESS_DB_USER: "wordpress_user"
    WORDPRESS_TABLE_PREFIX: "wp_"

controllers:
  main:
    containers:
      main:
        image:
          repository: "wordpress"
          tag: "6.4-apache"

persistence:
  app-data:
    enabled: true
    size: 20Gi
    globalMounts:
      - path: /var/www/html/wp-content
  uploads:
    enabled: true
    size: 50Gi
    globalMounts:
      - path: /var/www/html/wp-content/uploads
```

### Laravel

Laravel applications need specific environment variables and storage paths:

```yaml
# values-laravel.yaml
appConfig:
  configMap:
    APP_ENV: "production"
    APP_KEY: "base64:your-laravel-key"
    DB_CONNECTION: "mysql"
    CACHE_DRIVER: "file"
    SESSION_DRIVER: "file"

controllers:
  main:
    containers:
      main:
        image:
          repository: "your-registry/laravel-app"
          tag: "latest"

persistence:
  app-data:
    enabled: true
    size: 8Gi
    globalMounts:
      - path: /var/www/html/storage
  uploads:
    enabled: true
    size: 20Gi
    globalMounts:
      - path: /var/www/html/public/uploads
```

### Symfony

Symfony applications use different configuration patterns:

```yaml
# values-symfony.yaml
appConfig:
  configMap:
    APP_ENV: "prod"
    APP_SECRET: "your-symfony-secret"
    DATABASE_URL: "mysql://user:pass@mariadb:3306/symfony_db"
    TRUSTED_PROXIES: "127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

controllers:
  main:
    containers:
      main:
        image:
          repository: "your-registry/symfony-app"
          tag: "latest"

persistence:
  app-data:
    enabled: true
    size: 5Gi
    globalMounts:
      - path: /var/www/html/var
  uploads:
    enabled: true
    size: 10Gi
    globalMounts:
      - path: /var/www/html/public/uploads
```

## Advanced Configuration

### Multi-Replica Deployments

For high availability, configure multiple replicas with shared storage:

```yaml
controllers:
  main:
    replicas: 3

persistence:
  shared:
    enabled: true
    accessMode: ReadWriteMany  # Required for multi-replica
    globalMounts:
      - path: /var/www/html/public/uploads
```

### Health Checks

Configure appropriate health checks for your application:

```yaml
controllers:
  main:
    containers:
      main:
        probes:
          liveness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: 80
              initialDelaySeconds: 30
              periodSeconds: 10
          readiness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /ready
                port: 80
              initialDelaySeconds: 5
              periodSeconds: 5
```

### Resource Management

Set appropriate resource limits and requests:

```yaml
controllers:
  main:
    containers:
      main:
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 200m
            memory: 256Mi
```

## Security Considerations

1. **Secrets Management**: Use external secret management for sensitive values
2. **Network Policies**: Consider implementing network policies for isolation
3. **Pod Security**: Configure appropriate security contexts
4. **Image Security**: Use specific image tags and vulnerability scanning

## Troubleshooting

### Common Issues

1. **Database Connection**: Verify MariaDB operator and connection details
2. **Persistence**: Check storage class availability and permissions
3. **Ingress**: Verify ingress controller and DNS configuration
4. **Resources**: Monitor resource usage and adjust limits

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/instance=my-app

# View pod logs
kubectl logs -l app.kubernetes.io/instance=my-app -f

# Check persistent volumes
kubectl get pv,pvc

# Describe deployment
kubectl describe deployment my-app
```

## Dependencies

This chart depends on:
- [bjw-s common library](https://bjw-s.github.io/helm-charts/) (v4.0.1+)
- [MariaDB Library Chart](../mariadb-library-chart/) (for database integration)

## Values Reference

See the individual values files for complete configuration options:
- [`values.yaml`](./values.yaml) - Default values with all options
- [`values-wordpress.yaml`](./values-wordpress.yaml) - WordPress-specific configuration
- [`values-laravel.yaml`](./values-laravel.yaml) - Laravel-specific configuration
- [`values-symfony.yaml`](./values-symfony.yaml) - Symfony-specific configuration

## Contributing

When contributing to this chart:
1. Test with all supported frameworks
2. Update documentation for new features
3. Follow bjw-s common library patterns
4. Maintain backward compatibility
