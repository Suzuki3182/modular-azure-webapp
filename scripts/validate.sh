#!/bin/bash

# Validation script for Terraform configuration
# Usage: ./scripts/validate.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔍 Validating Terraform configuration..."

# Change to project root
cd "$PROJECT_ROOT"

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init -backend=false

# Format check
echo "📝 Checking Terraform formatting..."
if ! terraform fmt -check -recursive; then
    echo "❌ Terraform files are not properly formatted"
    echo "Run 'terraform fmt -recursive' to fix formatting issues"
    exit 1
fi

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Check for security issues (if tfsec is installed)
if command -v tfsec &> /dev/null; then
    echo "🔒 Running security checks..."
    tfsec .
else
    echo "⚠️  tfsec not installed - skipping security checks"
    echo "Install tfsec for security validation: https://github.com/aquasecurity/tfsec"
fi

echo ""
echo "✅ All validations passed!"
