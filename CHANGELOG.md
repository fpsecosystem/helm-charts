# Changelog

All notable changes to the FPS Ecosystem Helm Charts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2025-06-01

### Added
- **New Chart**: imagepullsecret-library-chart for managing Docker registry image pull secrets
- Multi-chart repository support with enhanced build infrastructure
- New scripts: `test-all-charts.sh` and `bump-version-multi.sh` for better multi-chart management

### Changed
- Updated GitHub Actions workflows to support multiple charts (both mariadb and imagepullsecret charts)
- Enhanced Makefile with multi-chart targets and convenience commands
- Improved README with comprehensive chart documentation and usage examples
- Updated gh-pages index to include both charts

### Infrastructure
- **ImagePullSecret Chart**: Application chart for creating Docker registry authentication secrets
- **Multi-Chart Workflows**: Automated testing and releasing for multiple charts
- **Enhanced Documentation**: Detailed installation examples for both chart types
- **Build System**: Comprehensive multi-chart support in all build scripts

## [0.1.0] - 2025-05-30

### Added
- Initial release of MariaDB Library Chart
- Support for creating MariaDB databases using the MariaDB operator
- Support for creating MariaDB users with password management
- Support for creating MariaDB grants with flexible permissions
- Automatic password generation with configurable length
- Support for existing password secrets
- Comprehensive documentation and examples
- GitHub Actions for automated testing and releases
- Development tools including Makefile, scripts, and pre-commit hooks

### Features
- **Database Management**: Create and configure MariaDB databases
- **User Management**: Create users with automatic password generation
- **Grant Management**: Configure database permissions for users
- **Secret Management**: Handle password secrets securely
- **Library Chart Pattern**: Reusable templates for easy integration
- **Configurable Options**: Extensive configuration options for all resources
- **Label & Annotation Support**: Custom labels and annotations for all resources

### Documentation
- Comprehensive README with usage examples
- Detailed installation guide with prerequisites
- Example application showing integration patterns
- Troubleshooting guide for common issues
- Development setup instructions

[Unreleased]: https://github.com/fpsecosystem/helm-charts/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fpsecosystem/helm-charts/releases/tag/v0.1.0
