# Multi-App Deployment Guide

This guide explains how to deploy multiple applications to the same Azure resource group using this template.

## How It Works

This template now supports **zero-hardcoding multi-app deployment** where:
1. **Automatic folder detection** - works with any folder structure
2. **Dynamic resource naming** - prevents conflicts automatically  
3. **All apps share the same resource group** for cost efficiency
4. **Zero configuration required** - everything is auto-detected
5. **No file editing needed** - completely automated

## Solution

### 1. Zero-Config Deployment Process

The template now includes a universal `deploy.sh` script that automatically handles everything.

#### Deploy First App:
```bash
# Auto-detects folder and deploys
./deploy.sh my-first-app
```

#### Deploy Second App (to same resource group):
```bash
# Auto-detects folder and deploys to same resource group
./deploy.sh my-second-app
```

#### Deploy Third App (to same resource group):
```bash
# Auto-detects folder and deploys to same resource group  
./deploy.sh my-third-app
```

### 2. What the Script Does Automatically

The `deploy.sh` script automatically:
1. **Detects your app folder** (whether renamed or default)
2. **Creates azd environment** if it doesn't exist
3. **Updates all paths dynamically** in azure.yaml
4. **Sets all environment variables** correctly
5. **Deploys to shared resource group** automatically
6. **Handles all naming conflicts** without manual intervention

### 3. What Happens Behind the Scenes

- **Resource Group**: Both apps use the same resource group (`my-shared-resource-group`)
- **Resource Naming**: Resources are named using the pattern: `{AZURE_ENV_NAME}-{AZURE_SERVICE_NAME}-{unique-hash}`
- **Service Tagging**: Each Function App gets tagged with `azd-service-name: {AZURE_SERVICE_NAME}`

### 4. Example Resource Names

With the setup above, you'll get resources like:

#### App 1 (`AZURE_SERVICE_NAME="my-first-app"`):
- Function App: `my-shared-resource-group-my-first-app-xyz123-function-app`
- Storage Account: `mysharedresourcegroupmyfirstappxyz123storage`
- App Service Plan: `my-shared-resource-group-my-first-app-xyz123-plan`

#### App 2 (`AZURE_SERVICE_NAME="my-second-app"`):
- Function App: `my-shared-resource-group-my-second-app-abc456-function-app`
- Storage Account: `mysharedresourcegroupmysecondappabc456storage`
- App Service Plan: `my-shared-resource-group-my-second-app-abc456-plan`

### 4. Troubleshooting

#### Error: "resource not found: unable to find a resource tagged with 'azd-service-name: ...'"

**Cause**: This should not happen with the new zero-config approach.

**Solution**: Use `./deploy.sh <app-name>` which handles all configuration automatically.

#### Error: "Resource group already exists"

**Cause**: This is expected when deploying multiple apps to the same resource group.

**Solution**: This is normal behavior. The deployment will continue and add your new app to the existing resource group.

#### Error: "WARNING: The current directory is not empty" during azd init

**Cause**: You're trying to initialize a second template in the same directory.

**Solution**: Use the `deploy.sh` script instead of `azd init` for additional apps:
```bash
./deploy.sh my-second-app
```

### 6. Best Practices

1. **Use descriptive service names**: `user-auth`, `payment-processor`, `notification-service`
2. **Keep environment names consistent**: Use the same `AZURE_ENV_NAME` for all apps that should share resources
3. **Document your setup**: Keep track of which service names you've used
4. **Use environment-specific configurations**: Different `AZURE_ENV_NAME` for dev, staging, prod

### 7. Environment File Template

Create a `.env` file for each app:

#### App 1 (.env):
```bash
AZURE_ENV_NAME=<my-shared-resource-group>
AZURE_SERVICE_NAME=<my-first-app>
AZURE_LOCATION=<location>
AZURE_SUBSCRIPTION_ID=<your-subscription-id>
```

#### App 2 (.env):
```bash
AZURE_ENV_NAME=<my-shared-resource-group>
AZURE_SERVICE_NAME=<my-second-app>
AZURE_LOCATION=<location>
AZURE_SUBSCRIPTION_ID=<your-subscription-id>
```

Then source the appropriate file before deployment:
```bash
source .env
azd up
```
