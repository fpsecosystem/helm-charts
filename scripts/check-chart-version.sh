#!/bin/bash

# Check if chart version has been bumped
set -e

CHART_YAML="mariadb-library-chart/Chart.yaml"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not in a git repository, skipping version check"
    exit 0
fi

# Check if Chart.yaml exists
if [ ! -f "$CHART_YAML" ]; then
    echo "Chart.yaml not found at $CHART_YAML"
    exit 1
fi

# Get current version from Chart.yaml
CURRENT_VERSION=$(grep '^version:' "$CHART_YAML" | sed 's/version: //' | tr -d '"' | tr -d ' ')

# Get version from the last commit (if it exists)
if git rev-parse HEAD~1 >/dev/null 2>&1; then
    PREVIOUS_VERSION=$(git show HEAD~1:"$CHART_YAML" 2>/dev/null | grep '^version:' | sed 's/version: //' | tr -d '"' | tr -d ' ' || echo "")

    if [ -n "$PREVIOUS_VERSION" ] && [ "$CURRENT_VERSION" = "$PREVIOUS_VERSION" ]; then
        echo "⚠️  Chart version hasn't been bumped (still $CURRENT_VERSION)"
        echo "💡 Use ./bump-version.sh [major|minor|patch] to bump the version"
        echo "ℹ️  If this is not a release commit, you can ignore this warning"
    else
        echo "✅ Chart version is $CURRENT_VERSION"
    fi
else
    echo "✅ Chart version is $CURRENT_VERSION (initial commit)"
fi
