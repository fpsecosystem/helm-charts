# Helm Charts

A collection of Helm charts for various applications and libraries.

## Charts

### mariadb-library-chart

A Helm library chart for managing MariaDB databases and users using the MariaDB operator.

- **Type**: Library Chart
- **Description**: Provides reusable templates for creating MariaDB databases, users, and grants
- **Version**: 0.1.0

[View Chart README](./mariadb-library-chart/README.md)

## Usage

### Adding as a Helm Repository

```bash
helm repo add fps-charts https://fpsecosystem.github.io/helm-charts
helm repo update
```

### Using as a Git Dependency

Add to your `Chart.yaml`:

```yaml
dependencies:
  - name: mariadb-library-chart
    version: "0.1.0"
    repository: "https://fpsecosystem.github.io/helm-charts"
```

### Using from GitHub

```yaml
dependencies:
  - name: mariadb-library-chart
    version: "0.1.0"
    repository: "git+https://github.com/fpsecosystem/helm-charts@mariadb-library-chart"
```

## Development

### Prerequisites

- Helm 3.2.0+
- chart-testing (ct)
- kind (for local testing)

### Testing

```bash
# Lint charts
ct lint --target-branch main

# Test charts
ct install --target-branch main
```

### Releasing

Charts are automatically released when changes are pushed to the `main` branch. The release process:

1. Packages the chart
2. Creates a GitHub release
3. Updates the Helm repository index
4. Publishes to GitHub Pages

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes locally
5. Submit a pull request

## License

This project is licensed under the MIT License.