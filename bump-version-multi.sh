#!/bin/bash

# Script to bump chart versions for multiple charts
set -e

CHARTS=("mariadb-library-chart" "imagepullsecret-library-chart")

function usage() {
    echo "Usage: $0 [chart-name] [major|minor|patch]"
    echo ""
    echo "Available charts:"
    for chart in "${CHARTS[@]}"; do
        echo "  - $chart"
    done
    echo ""
    echo "Version bump types:"
    echo "  major: bump major version (1.0.0 -> 2.0.0)"
    echo "  minor: bump minor version (1.0.0 -> 1.1.0)"
    echo "  patch: bump patch version (1.0.0 -> 1.0.1)"
    echo ""
    echo "Examples:"
    echo "  $0 mariadb-library-chart patch"
    echo "  $0 imagepullsecret-library-chart minor"
    exit 1
}

function get_current_version() {
    local chart_yaml="$1"
    grep '^version:' "$chart_yaml" | sed 's/version: //' | tr -d '"' | tr -d ' '
}

function bump_version() {
    local current_version="$1"
    local bump_type="$2"

    IFS='.' read -r -a version_parts <<< "$current_version"
    major="${version_parts[0]}"
    minor="${version_parts[1]}"
    patch="${version_parts[2]}"

    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo "Error: Invalid bump type '$bump_type'"
            usage
            ;;
    esac

    echo "$major.$minor.$patch"
}

# Check arguments
if [ $# -ne 2 ]; then
    usage
fi

CHART_DIR="$1"
BUMP_TYPE="$2"
CHART_YAML="$CHART_DIR/Chart.yaml"

# Validate chart name
if [[ ! " ${CHARTS[@]} " =~ " ${CHART_DIR} " ]]; then
    echo "Error: Invalid chart name '$CHART_DIR'"
    usage
fi

# Check if Chart.yaml exists
if [ ! -f "$CHART_YAML" ]; then
    echo "Error: $CHART_YAML not found"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(get_current_version "$CHART_YAML")
echo "Current version of $CHART_DIR: $CURRENT_VERSION"

# Calculate new version
NEW_VERSION=$(bump_version "$CURRENT_VERSION" "$BUMP_TYPE")
echo "New version: $NEW_VERSION"

# Update Chart.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$CHART_YAML"
else
    # Linux
    sed -i "s/^version: .*/version: $NEW_VERSION/" "$CHART_YAML"
fi

echo "✅ Updated $CHART_YAML with version $NEW_VERSION"

# Lint the chart to make sure it's still valid
echo "🔍 Linting chart..."
helm lint "$CHART_DIR"

echo "🎉 Version bump complete!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git diff"
echo "2. Update dependent charts if needed"
echo "3. Commit the changes: git add . && git commit -m 'chore: bump $CHART_DIR version to $NEW_VERSION'"
echo "4. Tag the release: git tag -a $CHART_DIR-v$NEW_VERSION -m 'Release $CHART_DIR v$NEW_VERSION'"
echo "5. Push: git push && git push --tags"
