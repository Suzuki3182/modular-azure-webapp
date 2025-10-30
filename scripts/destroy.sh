#!/bin/bash

# Destruction script for Azure infrastructure
# Usage: ./scripts/destroy.sh <environment>

set -e

ENVIRONMENT=${1:-cde}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔥 Destroying infrastructure for environment: $ENVIRONMENT"

# Check if environment file exists
if [ ! -f "$PROJECT_ROOT/environments/$ENVIRONMENT.tfvars" ]; then
    echo "❌ Environment file not found: environments/$ENVIRONMENT.tfvars"
    exit 1
fi

# Change to project root
cd "$PROJECT_ROOT"

# Plan destruction
echo "📋 Planning destruction..."
terraform plan -destroy -var-file="environments/$ENVIRONMENT.tfvars" -out="destroy-$ENVIRONMENT.tfplan"

# Ask for confirmation
echo ""
echo "⚠️  WARNING: This will destroy all infrastructure for the $ENVIRONMENT environment!"
read -p "Are you absolutely sure you want to continue? Type 'yes' to confirm: " -r
echo ""

if [[ $REPLY == "yes" ]]; then
    echo "🔨 Destroying infrastructure..."
    terraform apply "destroy-$ENVIRONMENT.tfplan"
    
    echo ""
    echo "✅ Infrastructure destroyed successfully!"
    
    # Clean up plan file
    rm -f "destroy-$ENVIRONMENT.tfplan"
else
    echo "❌ Destruction cancelled"
    rm -f "destroy-$ENVIRONMENT.tfplan"
    exit 1
fi
