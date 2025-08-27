#!/bin/bash

# Rename Integration Script
# This script helps you rename the backend-integration folder to your desired name
# and updates all necessary configuration files

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <new-integration-name> <repo-name>"
    echo ""
    echo "Parameters:"
    echo "  new-integration-name: The name for your new integration (required)"
    echo "  repo-name:            The repository name (required)"
    echo ""
    echo "Examples:"
    echo "  $0 shopify-integration my-shopify-repo"
    echo "  $0 payment-processor payment-backend"
    echo "  $0 email-service email-backend"
    exit 1
fi

NEW_NAME="$1"
REPO_NAME="$2"

# Validate the name format
if ! [[ "$NEW_NAME" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]]; then
    echo "Error: Name must start with a letter, contain only lowercase letters, numbers, and hyphens, and end with a letter or number"
    exit 1
fi

echo "Renaming integration from 'backend-integration' to '$NEW_NAME'..."
echo "Using repository name: '$REPO_NAME'"

# 1. Rename the main folder
if [ -d "backend-integration" ]; then
    mv backend-integration "$NEW_NAME"
    echo "✓ Renamed folder to $NEW_NAME/"
else
    echo "Warning: backend-integration folder not found"
fi

# 2. Update azure.yaml
if [ -f "azure.yaml" ]; then
    sed -i.bak "s|./backend-integration|./$NEW_NAME|g" azure.yaml
    rm azure.yaml.bak
    echo "✓ Updated azure.yaml"
fi

# 3. Update pyproject.toml
if [ -f "$NEW_NAME/pyproject.toml" ]; then
    sed -i.bak "s|name = \"{{appName}}\"|name = \"$NEW_NAME\"|g" "$NEW_NAME/pyproject.toml"
    rm "$NEW_NAME/pyproject.toml.bak"
    echo "✓ Updated $NEW_NAME/pyproject.toml"
fi

# 4. Update README.md and webapp files in the integration folder
if [ -f "$NEW_NAME/README.md" ]; then
    sed -i.bak "s|# {{appName}}|# $NEW_NAME|g" "$NEW_NAME/README.md"
    sed -i.bak "s|\"{{appName}}\"|\"$NEW_NAME\"|g" "$NEW_NAME/README.md"
    rm "$NEW_NAME/README.md.bak"
    echo "✓ Updated $NEW_NAME/README.md"
fi

# Update webapp main.py app_name
if [ -f "$NEW_NAME/webapp/main.py" ]; then
    sed -i.bak "s|'{{appName}}'|'$NEW_NAME'|g" "$NEW_NAME/webapp/main.py"
    rm "$NEW_NAME/webapp/main.py.bak"
    echo "✓ Updated $NEW_NAME/webapp/main.py"
fi

# 5. Clean up any extra workflow files and rename/update main workflow files
UPPER_NAME=$(echo "$NEW_NAME" | tr '[:lower:]' '[:upper:]' | sed 's/-/_/g')

# Remove any extra workflow files that shouldn't exist
if [ -f ".github/workflows/new-app-azure_deploy.yml" ]; then
    rm ".github/workflows/new-app-azure_deploy.yml"
    echo "✓ Removed extra new-app deployment workflow"
fi

if [ -f ".github/workflows/new-app-azure_bicep_validate.yml" ]; then
    rm ".github/workflows/new-app-azure_bicep_validate.yml"
    echo "✓ Removed extra new-app validation workflow"
fi

# Handle the main azure deployment workflow
if [ -f ".github/workflows/backend-integration-azure_deploy.yml" ]; then
    # Update content first
    sed -i.bak "s|backend-integration|$NEW_NAME|g" ".github/workflows/backend-integration-azure_deploy.yml"
    sed -i.bak "s|BACKEND_INTEGRATION|${UPPER_NAME}|g" ".github/workflows/backend-integration-azure_deploy.yml"
    sed -i.bak "s|Backend Integration|${NEW_NAME}|g" ".github/workflows/backend-integration-azure_deploy.yml"
    rm ".github/workflows/backend-integration-azure_deploy.yml.bak"
    
    # Then rename file
    mv ".github/workflows/backend-integration-azure_deploy.yml" ".github/workflows/$NEW_NAME-azure_deploy.yml"
    echo "✓ Updated and renamed deployment workflow"
fi

# Handle the azure bicep validation workflow
if [ -f ".github/workflows/backend-integration-azure_bicep_validate.yml" ]; then
    # Update content first
    sed -i.bak "s|backend-integration|$NEW_NAME|g" ".github/workflows/backend-integration-azure_bicep_validate.yml"
    sed -i.bak "s|Backend Integration|${NEW_NAME}|g" ".github/workflows/backend-integration-azure_bicep_validate.yml"
    rm ".github/workflows/backend-integration-azure_bicep_validate.yml.bak"
    
    # Then rename file
    mv ".github/workflows/backend-integration-azure_bicep_validate.yml" ".github/workflows/$NEW_NAME-azure_bicep_validate.yml"
    echo "✓ Updated and renamed validation workflow"
fi

# Handle the code validation and docs workflow
if [ -f ".github/workflows/backend-integration-code_validation_and_docs.yml" ]; then
    # Update content first - replace all instances of backend-integration
    sed -i.bak "s|backend-integration|$NEW_NAME|g" ".github/workflows/backend-integration-code_validation_and_docs.yml"
    # Update the workflow name/title
    sed -i.bak "s|Backend Integration - Checks & documentation|$NEW_NAME - Checks & documentation|g" ".github/workflows/backend-integration-code_validation_and_docs.yml"
    sed -i.bak "s|Backend Integration|$NEW_NAME|g" ".github/workflows/backend-integration-code_validation_and_docs.yml"
    # Update any references to the reusable workflow file
    sed -i.bak "s|backend-integration-dev-code_validation_and_docs.yml|$NEW_NAME-dev-code_validation_and_docs.yml|g" ".github/workflows/backend-integration-code_validation_and_docs.yml"
    # Update the repo-name parameter
    sed -i.bak "s|repo-name: azure-function-app-boilerplate|repo-name: $REPO_NAME|g" ".github/workflows/backend-integration-code_validation_and_docs.yml"
    rm ".github/workflows/backend-integration-code_validation_and_docs.yml.bak"
    
    # Then rename file
    mv ".github/workflows/backend-integration-code_validation_and_docs.yml" ".github/workflows/$NEW_NAME-code_validation_and_docs.yml"
    echo "✓ Updated and renamed code validation and docs workflow"
fi

# 6. Update main README.md
if [ -f "README.md" ]; then
    sed -i.bak "s|backend-integration|$NEW_NAME|g" README.md
    sed -i.bak "s|{{appName}}|$NEW_NAME|g" README.md
    rm README.md.bak
    echo "✓ Updated main README.md"
fi

# 7. Update azd-template.json
if [ -f "azd-template.json" ]; then
    sed -i.bak "s|backend-integration|$NEW_NAME|g" azd-template.json
    sed -i.bak "s|{{appName}}|$NEW_NAME|g" azd-template.json
    rm azd-template.json.bak
    echo "✓ Updated azd-template.json"
fi

echo ""
# 8. Remove the rename script from the newly created folder
if [ -f "$NEW_NAME/rename-integration.sh" ]; then
    rm "$NEW_NAME/rename-integration.sh"
    echo "✓ Removed rename-integration.sh from $NEW_NAME/"
fi

echo ""
echo "🎉 Successfully renamed integration to '$NEW_NAME'!"
echo "Repository name set to: '$REPO_NAME'"
echo ""
echo "Next steps:"
echo "1. cd $NEW_NAME/"
echo "2. Update your Azure environment variables to use ${UPPER_NAME}_* prefix"
echo "3. Run 'azd up' to deploy your integration"
echo ""
echo "Environment variables needed:"
echo "- ${UPPER_NAME}_ENV_NAME"
echo "- ${UPPER_NAME}_CLIENT_ID"
echo "- ${UPPER_NAME}_TENANT_ID"
echo "- ${UPPER_NAME}_SUBSCRIPTION_ID"
echo "- ${UPPER_NAME}_LOCATION"
echo ""
echo "Note: The workflow files have been updated with repository name: '$REPO_NAME'"
