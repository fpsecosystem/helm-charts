#!/bin/bash

# Test script to verify Helm repository functionality
set -e

REPO_NAME="fps-charts-test"
REPO_URL="https://fpsecosystem.github.io/helm-charts"

echo "🧪 Testing Helm repository functionality..."

# Clean up any existing repo with the same name
echo "🧹 Cleaning up existing test repository..."
helm repo remove "$REPO_NAME" 2>/dev/null || true

echo "📥 Adding Helm repository..."
helm repo add "$REPO_NAME" "$REPO_URL"

echo "🔄 Updating repository index..."
helm repo update

echo "📋 Listing available charts..."
helm search repo "$REPO_NAME"

echo "🔍 Showing chart information..."
echo ""
echo "=== MariaDB Library Chart ==="
helm show chart "$REPO_NAME/mariadb-library-chart" || echo "⚠️  MariaDB chart not yet available"

echo ""
echo "=== ImagePullSecret Chart ==="
helm show chart "$REPO_NAME/imagepullsecret-library-chart" || echo "⚠️  ImagePullSecret chart not yet available"

echo ""
echo "🧹 Cleaning up test repository..."
helm repo remove "$REPO_NAME"

echo "✅ Repository test complete!"
