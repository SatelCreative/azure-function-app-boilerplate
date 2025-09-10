#!/bin/bash

# Universal Deployment Script
# This script automatically detects the app folder and configures deployment
# No hardcoding required - works with any folder structure

set -e

# Function to display usage
show_usage() {
    echo "Usage: $0 [app-name]"
    echo ""
    echo "This script creates a new app folder and deploys it to Azure."
    echo "Each app gets its own folder with independent code and configuration."
    echo ""
    echo "Parameters:"
    echo "  app-name: Name for the app (creates folder with this name)."
    echo "           If not provided, uses current azd environment."
    echo ""
    echo "Environment Variables:"
    echo "  AZURE_ENV_NAME: Optional. Environment name (becomes the resource group name)"
    echo "  TEMPLATE_URL: Optional. Template repository URL (defaults to auto-detect)"
    echo ""
    echo "Examples:"
    echo "  $0 my-first-app                                    # Creates my-first-app/ folder"
    echo "  $0 my-second-app                                   # Creates my-second-app/ folder"
    echo "  AZURE_RESOURCE_GROUP=my-rg $0 my-third-app         # Uses custom resource group"
    echo "  $0                                                 # Uses current azd environment"
    echo ""
    echo "What happens:"
    echo "  1. Creates <app-name>/ folder with template code"
    echo "  2. Fetches template from repository if not available locally"
    echo "  3. Configures azure.yaml for the new folder"
    echo "  4. Deploys to SHARED resource group with unique app names"
}

# Get environment name
if [ $# -eq 1 ]; then
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    fi
    ENV_NAME="$1"
else
    # Get current environment name from azd
    ENV_NAME=$(azd env get-value AZURE_ENV_NAME 2>/dev/null || echo "")
    if [ -z "$ENV_NAME" ]; then
        echo "❌ No environment name provided and no current azd environment found."
        echo "   Please provide an environment name or run 'azd env new <name>' first."
        echo ""
        show_usage
        exit 1
    fi
fi

echo "🚀 Deploying app: $ENV_NAME"

# Create or use app folder
APP_FOLDER="$ENV_NAME"

if [ -d "$APP_FOLDER" ]; then
    echo "📁 Using existing app folder: $APP_FOLDER"
else
    echo "📁 Creating new app folder: $APP_FOLDER"
    
    # Copy template structure to new app folder
    mkdir -p "$APP_FOLDER"
    
    # Copy all necessary files from backend-integration template
    if [ -d "backend-integration" ]; then
        cp -r backend-integration/* "$APP_FOLDER/"
        echo "✅ Copied template files from local backend-integration to $APP_FOLDER/"
    else
        echo "📥 backend-integration not found locally. Fetching from template repository..."
        
        # Try to get the template from git remote or use a default template URL
        TEMPLATE_URL=""
        
        # Check if TEMPLATE_URL is set as environment variable
        if [ -n "${TEMPLATE_URL:-}" ]; then
            echo "📡 Using template from environment variable: $TEMPLATE_URL"
        else
            # Check if we're in a template repository by looking for backend-integration in the remote
            if git remote -v | grep -q "origin"; then
                ORIGIN_URL=$(git remote get-url origin)
                echo "📡 Found git remote: $ORIGIN_URL"
                
                # Check if this looks like a template repository
                if [[ "$ORIGIN_URL" == *"template"* ]] || [[ "$ORIGIN_URL" == *"SatelCreative"* ]]; then
                    TEMPLATE_URL="$ORIGIN_URL"
                    echo "📡 Using template from current repository: $TEMPLATE_URL"
                else
                    echo "⚠️  Current repository doesn't appear to be a template repository"
                    TEMPLATE_URL="https://github.com/SatelCreative/azure-function-app-boilerplate.git"
                    echo "📡 Using default template: $TEMPLATE_URL"
                fi
            else
                # Default template URL - you can change this to your template repo
                TEMPLATE_URL="https://github.com/SatelCreative/azure-function-app-boilerplate.git"
                echo "📡 Using default template: $TEMPLATE_URL"
            fi
        fi
        
        # Create a temporary directory to clone the template
        TEMP_DIR=$(mktemp -d)
        echo "📁 Cloning template to temporary directory..."
        
        if git clone --depth 1 "$TEMPLATE_URL" "$TEMP_DIR"; then
            if [ -d "$TEMP_DIR/backend-integration" ]; then
                cp -r "$TEMP_DIR/backend-integration"/* "$APP_FOLDER/"
                echo "✅ Copied template files from repository to $APP_FOLDER/"
            else
                echo "❌ backend-integration folder not found in template repository"
                rm -rf "$TEMP_DIR"
                exit 1
            fi
            rm -rf "$TEMP_DIR"
        else
            echo "❌ Failed to clone template repository. Please check your internet connection and repository URL."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    fi
fi

# Set up azd environment - use environment name from environment or prompt user
if [ -n "${AZURE_ENV_NAME:-}" ]; then
    SHARED_ENV_NAME="$AZURE_ENV_NAME"
    echo "🔧 Using environment name from environment: $SHARED_ENV_NAME"
else
    # Prompt user for environment name (which becomes the resource group name)
    echo "📝 Please enter the Azure environment name for this app:"
    echo "   (This will be the resource group name and shared across all your apps)"
    read -p "   Environment name: " SHARED_ENV_NAME
    
    if [ -z "$SHARED_ENV_NAME" ]; then
        echo "❌ Environment name cannot be empty"
        exit 1
    fi
    
    echo "🔧 Using environment name: $SHARED_ENV_NAME"
fi

if ! azd env list | grep -q "^$SHARED_ENV_NAME "; then
    echo "🔧 Creating shared azd environment: $SHARED_ENV_NAME"
    azd env new "$SHARED_ENV_NAME" --subscription "${AZURE_SUBSCRIPTION_ID:-}" --location "${AZURE_LOCATION:-West US}"
else
    echo "🔧 Using existing shared azd environment: $SHARED_ENV_NAME"
fi

azd env select "$SHARED_ENV_NAME"

# Set environment variables dynamically
# Use shared resource group for all apps, but unique service names
azd env set AZURE_ENV_NAME "$SHARED_ENV_NAME"
azd env set AZURE_SERVICE_NAME "$ENV_NAME"

echo "✅ Environment configured:"
echo "   AZURE_ENV_NAME=$SHARED_ENV_NAME"
echo "   AZURE_SERVICE_NAME=$ENV_NAME"
echo "   App Folder: $APP_FOLDER"

# Update azure.yaml to point to the app folder and use correct service name
echo "🔧 Updating azure.yaml for folder: $APP_FOLDER"

# Create backup if it doesn't exist
if [ ! -f "azure.yaml.original" ]; then
    cp azure.yaml azure.yaml.original
fi

# Create a new azure.yaml with dynamic values
cat > azure.yaml << EOF
# yaml-language-server: \$schema=https://raw.githubusercontent.com/Azure/azure-dev/main/schemas/v1.0/azure.yaml.json

name: azure-function-app-boilerplate
metadata:
  template: azure-function-app-boilerplate@1.0.0
  author: Azure Function App Template
  description: A comprehensive Azure Function App boilerplate with Shopify integration, FastAPI, and complete infrastructure as code

services:
  $ENV_NAME:
    project: ./$APP_FOLDER
    language: py
    host: function

infra:
  provider: bicep
  path: ./$APP_FOLDER/infra
  parameters:
    serviceName: "\${AZURE_SERVICE_NAME:=api}"

pipeline:
  provider: github
EOF

echo "✅ Updated azure.yaml paths and service name"

echo ""
echo "🚀 Starting deployment..."
echo ""

# Deploy
azd up

echo ""
echo "🎉 Deployment complete!"
echo "🔄 To deploy another app to the same resource group, run:"
echo "   $0 <different-app-name>"
