#!/bin/bash

# Setup script for multi-chart Helm repository development
set -e

echo "🚀 Setting up Multi-Chart Helm Repository development environment..."

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Helm
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm 3.2.0+"
    echo "   Visit: https://helm.sh/docs/intro/install/"
    exit 1
fi

HELM_VERSION=$(helm version --short --client | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
echo "✅ Helm found: $HELM_VERSION"

# Check kubectl (optional but recommended)
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl found"
else
    echo "⚠️  kubectl not found (optional for development)"
fi

# Check git
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed"
    exit 1
fi
echo "✅ Git found"

# Optional tools
echo ""
echo "🔧 Checking optional development tools..."

if command -v pre-commit &> /dev/null; then
    echo "✅ pre-commit found"
    echo "   Setting up pre-commit hooks..."
    pre-commit install
else
    echo "⚠️  pre-commit not found (optional)"
    echo "   Install with: pip install pre-commit"
fi

if command -v ct &> /dev/null; then
    echo "✅ chart-testing (ct) found"
else
    echo "⚠️  chart-testing not found (optional)"
    echo "   Install from: https://github.com/helm/chart-testing"
fi

if command -v helm-docs &> /dev/null; then
    echo "✅ helm-docs found"
else
    echo "⚠️  helm-docs not found (optional)"
    echo "   Install from: https://github.com/norwoodj/helm-docs"
fi

# Test the chart
echo ""
echo "🧪 Testing the chart..."
make lint
make test

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📚 Next steps:"
echo "   1. Read the documentation: cat README.md"
echo "   2. Review the example: ls examples/simple-app/"
echo "   3. Test locally: make test"
echo "   4. See available commands: make help"
echo ""
echo "🔗 Useful links:"
echo "   - Project summary: cat PROJECT-SUMMARY.md"
echo "   - Installation guide: cat INSTALLATION.md"
echo "   - MariaDB Operator: https://github.com/mariadb-operator/mariadb-operator"
echo ""
echo "Happy charting! 🎯"