#!/bin/bash

# Deployment script for Azure infrastructure
# Usage: ./scripts/deploy.sh <environment>

set -e

ENVIRONMENT=${1:-cde}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Deploying infrastructure for environment: $ENVIRONMENT"

# Check if environment file exists
if [ ! -f "$PROJECT_ROOT/environments/$ENVIRONMENT.tfvars" ]; then
    echo "❌ Environment file not found: environments/$ENVIRONMENT.tfvars"
    echo "Available environments:"
    ls -1 "$PROJECT_ROOT/environments/"*.tfvars 2>/dev/null | xargs -n 1 basename | sed 's/.tfvars$//' || echo "No environment files found"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -var-file="environments/$ENVIRONMENT.tfvars" -out="$ENVIRONMENT.tfplan"

# Ask for confirmation
echo ""
read -p "Do you want to apply this plan? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔨 Applying infrastructure changes..."
    terraform apply "$ENVIRONMENT.tfplan"
    
    echo ""
    echo "✅ Deployment completed successfully!"
    echo ""
    echo "📊 Infrastructure outputs:"
    terraform output
    
    # Clean up plan file
    rm -f "$ENVIRONMENT.tfplan"
else
    echo "❌ Deployment cancelled"
    rm -f "$ENVIRONMENT.tfplan"
    exit 1
fi
