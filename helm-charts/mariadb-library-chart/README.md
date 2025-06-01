# MariaDB Library Chart

A Helm library chart for managing MariaDB databases and users using the [MariaDB Operator](https://github.com/mariadb-operator/mariadb-operator).

## Description

This library chart provides reusable templates for creating MariaDB databases, users, and grants using the MariaDB Operator. It's designed to be used as a dependency in other Helm charts.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- [MariaDB Operator](https://github.com/mariadb-operator/mariadb-operator) installed in your cluster
- A MariaDB instance managed by the MariaDB Operator

## Installation

This is a library chart and cannot be installed directly. It should be used as a dependency in other charts.

### Using as a Dependency

Add this chart as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: mariadb-library-chart
    version: "0.1.0"
    repository: "https://fpsecosystem.github.io/helm-charts"
```

Then in your templates, you can use the templates like this:

```yaml
# In your chart's templates/database.yaml
{{ include "mariadb-library.database" . }}
---
{{ include "mariadb-library.user" . }}
---
{{ include "mariadb-library.grant" . }}
```

### Using from GitHub

If you're hosting this chart on GitHub, you can reference it directly:

```yaml
dependencies:
  - name: mariadb-library-chart
    version: "0.1.0"
    repository: "https://github.com/fpsecosystem/helm-charts"
```

## Configuration

The following table lists the configurable parameters and their default values.

### Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.mariadbOperatorNamespace` | Namespace where MariaDB operator is installed | `mariadb-system` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.enabled` | Enable database creation | `true` |
| `database.name` | Database name (auto-generated if empty) | `""` |
| `database.mariaDbRef.name` | Name of the MariaDB instance | `mariadb` |
| `database.mariaDbRef.namespace` | Namespace of MariaDB instance | `""` (release namespace) |
| `database.characterSet` | Character set for the database | `utf8mb4` |
| `database.collate` | Collation for the database | `utf8mb4_unicode_ci` |
| `database.labels` | Additional labels for database resource | `{}` |
| `database.annotations` | Additional annotations for database resource | `{}` |

### User Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `user.enabled` | Enable user creation | `true` |
| `user.name` | Username (auto-generated if empty) | `""` |
| `user.passwordSecret.name` | Name of password secret (auto-generated if empty) | `""` |
| `user.passwordSecret.key` | Key in secret containing password | `password` |
| `user.passwordSecret.generate` | Generate secret with random password | `false` |
| `user.passwordSecret.passwordLength` | Length of generated password | `16` |
| `user.host` | Host from which user can connect | `%` |
| `user.mariaDbRef.name` | Name of the MariaDB instance | `mariadb` |
| `user.mariaDbRef.namespace` | Namespace of MariaDB instance | `""` (release namespace) |
| `user.maxUserConnections` | Maximum user connections | `10` |
| `user.labels` | Additional labels for user resource | `{}` |
| `user.annotations` | Additional annotations for user resource | `{}` |

### Grant Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `grant.enabled` | Enable grant creation | `true` |
| `grant.database` | Database to grant permissions on | `""` (uses database name) |
| `grant.username` | User to grant permissions to | `""` (uses username) |
| `grant.table` | Table to grant permissions on | `*` |
| `grant.privileges` | List of privileges to grant | `["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP", "INDEX", "ALTER"]` |
| `grant.host` | Host from which user can connect | `%` |
| `grant.mariaDbRef.name` | Name of the MariaDB instance | `mariadb` |
| `grant.mariaDbRef.namespace` | Namespace of MariaDB instance | `""` (release namespace) |
| `grant.labels` | Additional labels for grant resource | `{}` |
| `grant.annotations` | Additional annotations for grant resource | `{}` |

### Common Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `commonLabels` | Labels applied to all resources | `{}` |
| `commonAnnotations` | Annotations applied to all resources | `{}` |

## Usage Examples

### Basic Usage

```yaml
# values.yaml
database:
  enabled: true
  name: "myapp-db"
  mariaDbRef:
    name: "my-mariadb"

user:
  enabled: true
  name: "myapp-user"
  passwordSecret:
    generate: true
    passwordLength: 20

grant:
  enabled: true
  privileges:
    - "SELECT"
    - "INSERT"
    - "UPDATE"
    - "DELETE"
```

### Using Existing Secret

```yaml
# values.yaml
user:
  enabled: true
  name: "myapp-user"
  passwordSecret:
    name: "existing-password-secret"
    key: "password"
    generate: false
```

### Custom Privileges

```yaml
# values.yaml
grant:
  enabled: true
  privileges:
    - "SELECT"
    - "INSERT"
  table: "users"
```

### Multiple Databases

You can use this library chart multiple times in the same parent chart by using different release names or by creating multiple template files.

## Templates

This library chart provides the following templates:

- `database.yaml` - Creates a MariaDB Database resource
- `user.yaml` - Creates a MariaDB User resource
- `secret.yaml` - Creates a Secret for the user password (when `generate: true`)
- `grant.yaml` - Creates a MariaDB Grant resource

## Helper Functions

The chart includes several helper functions in `_helpers.tpl`:

- `mariadb-library.name` - Chart name
- `mariadb-library.fullname` - Full application name
- `mariadb-library.labels` - Common labels
- `mariadb-library.databaseName` - Database name (with fallback)
- `mariadb-library.username` - Username (with fallback)
- `mariadb-library.passwordSecretName` - Password secret name (with fallback)

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
