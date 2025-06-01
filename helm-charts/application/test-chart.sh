#!/bin/bash

# Test script for the application chart (now dynamic for charts dir)
set -e

CHARTS_DIR="../../charts"

# Find all chart directories (skip hidden files and non-directories)
CHARTS=()
for dir in "$CHARTS_DIR"/*; do
  if [ -d "$dir" ] && [ -f "$dir/Chart.yaml" ]; then
    CHARTS+=("$dir")
  fi

done

echo "🧪 Testing all charts in $CHARTS_DIR..."

for CHART_DIR in "${CHARTS[@]}"; do
    CHART_NAME=$(basename "$CHART_DIR")
    echo ""
    echo "📊 Testing $CHART_NAME..."

    echo "🔍 Linting chart..."
    helm lint "$CHART_DIR"

    echo "📦 Packaging chart..."
    helm package "$CHART_DIR"

    echo "🧪 Testing template rendering..."
    # Check if this is a library chart
    CHART_TYPE=$(grep "^type:" "$CHART_DIR/Chart.yaml" | awk '{print $2}' || echo "application")

    if [ "$CHART_TYPE" = "library" ]; then
        echo "📚 Skipping template rendering for library chart $CHART_NAME"
        echo "   Library charts are meant to be used as dependencies"
    else
        if [ -f "$CHART_DIR/values-example.yaml" ]; then
            helm template test-release "$CHART_DIR" \
              --values "$CHART_DIR/values-example.yaml" \
              --namespace test-namespace \
              --dry-run
        else
            helm template test-release "$CHART_DIR" \
              --namespace test-namespace \
              --dry-run
        fi
    fi

    echo "✅ $CHART_NAME tests passed!"
done

echo ""
echo "🧹 Cleaning up packages..."
rm -f $CHARTS_DIR/*-library-chart-*.tgz

echo ""
echo "🎉 All charts are ready for use!"
