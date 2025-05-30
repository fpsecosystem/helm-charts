#!/bin/bash

# Test script for mariadb-library-chart
set -e

CHART_DIR="mariadb-library-chart"
TEST_NAMESPACE="mariadb-test"

echo "🔍 Linting chart..."
helm lint "$CHART_DIR"

echo "📦 Packaging chart..."
helm package "$CHART_DIR"

echo "🧪 Testing template rendering..."
helm template test-release "$CHART_DIR" \
  --values "$CHART_DIR/values-example.yaml" \
  --namespace "$TEST_NAMESPACE" \
  --dry-run

echo "✅ All tests passed!"

# Cleanup
rm -f mariadb-library-chart-*.tgz

echo "🎉 Chart is ready for use!"
