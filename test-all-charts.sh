#!/bin/bash

# Test script for all charts
set -e

CHARTS=("mariadb-library-chart" "imagepullsecret-library-chart")

echo "🧪 Testing all charts..."

for CHART_DIR in "${CHARTS[@]}"; do
    if [ ! -d "$CHART_DIR" ]; then
        echo "⚠️  Chart directory $CHART_DIR not found, skipping..."
        continue
    fi

    echo ""
    echo "📊 Testing $CHART_DIR..."

    echo "🔍 Linting chart..."
    helm lint "$CHART_DIR"

    echo "📦 Packaging chart..."
    helm package "$CHART_DIR"

    echo "🧪 Testing template rendering..."
    # Check if this is a library chart
    CHART_TYPE=$(grep "^type:" "$CHART_DIR/Chart.yaml" | awk '{print $2}' || echo "application")

    if [ "$CHART_TYPE" = "library" ]; then
        echo "📚 Skipping template rendering for library chart $CHART_DIR"
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

    echo "✅ $CHART_DIR tests passed!"
done

echo ""
echo "🧹 Cleaning up packages..."
rm -f *-library-chart-*.tgz

echo ""
echo "🎉 All charts are ready for use!"
