# FPS Ecosystem Helm Charts

Welcome to the FPS Ecosystem Helm Charts repository! This repository contains production-ready Helm charts for Kubernetes applications and infrastructure components.

## 📦 Available Charts

### MariaDB Library Chart
[![Chart Version](https://img.shields.io/badge/Chart-0.1.2-blue)](https://github.com/fpsecosystem/helm-charts/releases/tag/mariadb-library-chart-0.1.2)
[![Type](https://img.shields.io/badge/Type-Library-orange)](https://helm.sh/docs/topics/library_charts/)

A Helm library chart for managing MariaDB databases and users using the MariaDB Operator.

**Features:**
- 🗃️ Database creation and management
- 👤 User management with custom permissions
- 🔐 Secure password generation and storage
- 🔗 Grant management for fine-grained access control
- 📊 Integration with MariaDB Operator

**Usage:**
```yaml
dependencies:
  - name: mariadb-library-chart
    version: "0.1.2"
    repository: "https://fpsecosystem.github.io/helm-charts"
```

[📖 View Documentation](https://github.com/fpsecosystem/helm-charts/tree/main/mariadb-library-chart) | [⬇️ Download](https://github.com/fpsecosystem/helm-charts/releases/tag/mariadb-library-chart-0.1.2)

---

### Image Pull Secret Chart
[![Chart Version](https://img.shields.io/badge/Chart-0.1.3-blue)](https://github.com/fpsecosystem/helm-charts/releases/tag/imagepullsecret-library-chart-0.1.3)
[![Type](https://img.shields.io/badge/Type-Application-green)](https://helm.sh/docs/topics/charts/)

A Helm application chart for managing Docker registry image pull secrets.

**Features:**
- 🐳 Docker registry authentication
- 🔑 Secure credential management
- 🎯 Multiple registry support
- 📝 Automatic secret generation
- 🔄 Easy integration with existing workloads

**Usage:**
```yaml
dependencies:
  - name: imagepullsecret-library-chart
    version: "0.1.3"
    repository: "https://fpsecosystem.github.io/helm-charts"
```

[📖 View Documentation](https://github.com/fpsecosystem/helm-charts/tree/main/imagepullsecret-library-chart) | [⬇️ Download](https://github.com/fpsecosystem/helm-charts/releases/tag/imagepullsecret-library-chart-0.1.3)

---

### Universal PHP Application Chart
[![Chart Version](https://img.shields.io/badge/Chart-0.3.0-blue)](https://github.com/fpsecosystem/helm-charts/releases/tag/application-0.3.0)
[![Type](https://img.shields.io/badge/Type-Application-green)](https://helm.sh/docs/topics/charts/)

A universal Helm chart for deploying PHP applications including WordPress, Laravel, Symfony, and other PHP frameworks.

**Features:**
- 🌐 Universal support for WordPress, Laravel, Symfony, and any PHP application
- 💾 Flexible persistence with bjw-s common library patterns
- 🗄️ Built-in MariaDB operator integration with automatic connection
- ⚙️ Dynamic ConfigMap-based environment variable management
- ⚡ High availability with multi-replica support and shared storage
- 🔐 Secure handling of sensitive and non-sensitive configuration
- 📱 Modern Kubernetes patterns using bjw-s common library

**Quick Deploy Examples:**
```bash
# Deploy WordPress
helm install my-wordpress fps-charts/application -f values-wordpress.yaml

# Deploy Laravel
helm install my-laravel fps-charts/application -f values-laravel.yaml

# Deploy Symfony
helm install my-symfony fps-charts/application -f values-symfony.yaml
```

**Framework-Specific Values:**
- `values-wordpress.yaml` - WordPress-optimized configuration
- `values-laravel.yaml` - Laravel-optimized configuration  
- `values-symfony.yaml` - Symfony-optimized configuration

[📖 View Documentation](https://github.com/fpsecosystem/helm-charts/tree/main/application) | [⬇️ Download](https://github.com/fpsecosystem/helm-charts/releases/tag/application-0.3.0)

## 🚀 Quick Start

### 1. Add the Helm Repository

```bash
helm repo add fps-charts https://fpsecosystem.github.io/helm-charts
helm repo update
```

### 2. Search Available Charts

```bash
helm search repo fps-charts
```

### 3. Install a Chart

For application charts:
```bash
# Install the imagepullsecret chart
helm install my-secrets fps-charts/imagepullsecret-library-chart --values my-values.yaml
```

For library charts (as dependencies):
```yaml
# In your Chart.yaml
dependencies:
  - name: mariadb-library-chart
    version: "0.1.2"
    repository: "https://fpsecosystem.github.io/helm-charts"
```

## 📋 Prerequisites

- **Kubernetes**: 1.19+
- **Helm**: 3.2.0+
- **MariaDB Operator**: Required for MariaDB Library Chart

## 🔧 Configuration

Each chart comes with comprehensive configuration options. Check the individual chart documentation for detailed configuration examples and best practices.

## 📚 Documentation

- [MariaDB Library Chart Documentation](https://github.com/fpsecosystem/helm-charts/tree/main/mariadb-library-chart)
- [Image Pull Secret Chart Documentation](https://github.com/fpsecosystem/helm-charts/tree/main/imagepullsecret-library-chart)
- [GitHub Repository](https://github.com/fpsecosystem/helm-charts)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](https://github.com/fpsecosystem/helm-charts/blob/main/CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/fpsecosystem/helm-charts/blob/main/LICENSE) file for details.

## 📞 Support

- 🐛 [Report Issues](https://github.com/fpsecosystem/helm-charts/issues)
- 💬 [Discussions](https://github.com/fpsecosystem/helm-charts/discussions)
- 📧 Email: contact@fpsecosystem.org

---

## 📊 Repository Statistics

| Chart | Version | Type | Downloads |
|-------|---------|------|-----------|
| [mariadb-library-chart](https://github.com/fpsecosystem/helm-charts/tree/main/mariadb-library-chart) | 0.1.2 | Library | [![Downloads](https://img.shields.io/github/downloads/fpsecosystem/helm-charts/mariadb-library-chart-0.1.2/total)](https://github.com/fpsecosystem/helm-charts/releases/tag/mariadb-library-chart-0.1.2) |
| [imagepullsecret-library-chart](https://github.com/fpsecosystem/helm-charts/tree/main/imagepullsecret-library-chart) | 0.1.3 | Application | [![Downloads](https://img.shields.io/github/downloads/fpsecosystem/helm-charts/imagepullsecret-library-chart-0.1.3/total)](https://github.com/fpsecosystem/helm-charts/releases/tag/imagepullsecret-library-chart-0.1.3) |

*Last updated: June 1, 2025*
