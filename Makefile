.PHONY: help lint test package clean install-deps

CHART_DIR := mariadb-library-chart
CHART_NAME := mariadb-library-chart

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-deps: ## Install development dependencies
	@echo "Installing development dependencies..."
	@which helm >/dev/null || (echo "❌ Helm not found. Please install Helm 3.2.0+" && exit 1)
	@echo "✅ Helm found"
	@which ct >/dev/null || (echo "❌ chart-testing not found. Please install ct" && exit 1)
	@echo "✅ chart-testing found"

lint: ## Lint the Helm chart
	@echo "🔍 Linting chart..."
	@helm lint $(CHART_DIR)
	@echo "✅ Lint passed"

test: lint ## Test the Helm chart templates
	@echo "🧪 Testing chart templates..."
	@echo "📝 Validating YAML syntax..."
	@find $(CHART_DIR)/templates -name "*.yaml" -exec yamllint -d relaxed {} \; 2>/dev/null || echo "⚠️  yamllint not found, skipping YAML validation"
	@echo "🔍 Checking template files exist..."
	@test -f $(CHART_DIR)/templates/_helpers.tpl || (echo "❌ _helpers.tpl missing" && exit 1)
	@test -f $(CHART_DIR)/templates/database.yaml || (echo "❌ database.yaml missing" && exit 1)
	@test -f $(CHART_DIR)/templates/user.yaml || (echo "❌ user.yaml missing" && exit 1)
	@test -f $(CHART_DIR)/templates/grant.yaml || (echo "❌ grant.yaml missing" && exit 1)
	@test -f $(CHART_DIR)/templates/secret.yaml || (echo "❌ secret.yaml missing" && exit 1)
	@echo "✅ Template test passed"

package: lint ## Package the Helm chart
	@echo "📦 Packaging chart..."
	@helm package $(CHART_DIR)
	@echo "✅ Chart packaged"

clean: ## Clean generated files
	@echo "🧹 Cleaning up..."
	@rm -f $(CHART_NAME)-*.tgz
	@echo "✅ Cleanup complete"

ct-lint: ## Run chart-testing lint
	@echo "🔍 Running chart-testing lint..."
	@ct lint --target-branch main --chart-dirs .

ct-install: ## Run chart-testing install (requires kind cluster)
	@echo "🧪 Running chart-testing install..."
	@ct install --target-branch main --chart-dirs .

release-dry-run: package ## Simulate a release
	@echo "🚀 Simulating release..."
	@echo "Would release: $(shell ls $(CHART_NAME)-*.tgz)"
	@echo "✅ Dry run complete"

bump-major: ## Bump major version
	@./bump-version.sh major

bump-minor: ## Bump minor version
	@./bump-version.sh minor

bump-patch: ## Bump patch version
	@./bump-version.sh patch

setup-dev: ## Setup development environment
	@echo "🔧 Setting up development environment..."
	@which pre-commit >/dev/null || (echo "❌ pre-commit not found. Install with: pip install pre-commit" && exit 1)
	@pre-commit install
	@echo "✅ Development environment setup complete"

validate-example: ## Validate the example chart
	@echo "🧪 Validating example chart..."
	@cd examples/simple-app && helm dependency update
	@cd examples/simple-app && helm lint .
	@cd examples/simple-app && helm template test-release . --dry-run > /dev/null
	@echo "✅ Example validation complete"

docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	@helm-docs || (echo "❌ helm-docs not found. Install from: https://github.com/norwoodj/helm-docs" && exit 1)
	@echo "✅ Documentation generated"

changelog: ## View changelog
	@echo "📋 Recent changes:"
	@head -n 20 CHANGELOG.md

check-license: ## Check license compliance
	@echo "⚖️  Checking license..."
	@test -f LICENSE || (echo "❌ LICENSE file missing" && exit 1)
	@echo "✅ License file found"

all: install-deps lint test package ## Run all checks and build
