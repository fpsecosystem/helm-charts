#!/bin/bash

# Script to bump chart versions
set -e

CHART_DIR="mariadb-library-chart"
CHART_YAML="$CHART_DIR/Chart.yaml"

function usage() {
    echo "Usage: $0 [major|minor|patch]"
    echo "  major: bump major version (1.0.0 -> 2.0.0)"
    echo "  minor: bump minor version (1.0.0 -> 1.1.0)"
    echo "  patch: bump patch version (1.0.0 -> 1.0.1)"
    exit 1
}

function get_current_version() {
    grep '^version:' "$CHART_YAML" | sed 's/version: //' | tr -d '"'
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
if [ $# -ne 1 ]; then
    usage
fi

BUMP_TYPE="$1"

# Check if Chart.yaml exists
if [ ! -f "$CHART_YAML" ]; then
    echo "Error: $CHART_YAML not found"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(get_current_version)
echo "Current version: $CURRENT_VERSION"

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
echo "2. Commit the changes: git add . && git commit -m 'chore: bump version to $NEW_VERSION'"
echo "3. Tag the release: git tag -a v$NEW_VERSION -m 'Release v$NEW_VERSION'"
echo "4. Push: git push && git push --tags"
