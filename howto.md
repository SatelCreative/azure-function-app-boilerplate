# Azure Function App Boilerplate Template

A comprehensive Azure Function App boilerplate with Shopify integration, FastAPI, and complete infrastructure as code. This template provides a production-ready foundation for building serverless applications with Azure Functions.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/)

## 🚀 Quick Start

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- [Python 3.12+](https://www.python.org/downloads/)
- [Poetry](https://python-poetry.org/docs/#installation) (for local development)

### Using this Template

1. **Initialize a new project from this template:**
   ```bash
   cd your-project-name-repository 
   azd init --template https://github.com/SatelCreative/azure-function-app-boilerplate
   ./rename-integration.sh <APP-NAME>
   
   ```

2. **Configure your environment:**
   ```bash
   # Copy the example configuration
   cp backend-integration/config.sh.example backend-integration/config.sh
   cp backend-integration/local.settings.json.example backend-integration/local.settings.json
   
   # Edit the configuration files with your specific values
   ```

3. **Deploy to Azure:**
   ```bash
   azd up
   ```

   This will:
   - Create a new resource group
   - Deploy all Azure resources (Functions, Storage, App Insights, etc.)
   - Deploy your application code
   - Configure all necessary app settings

## 🏗️ What's Included

### Azure Resources
- **Azure Functions**: Python 3.12 runtime on consumption plan
- **Storage Account**: Required for Azure Functions runtime
- **Application Insights**: Comprehensive monitoring and logging
- **Log Analytics Workspace**: Centralized logging and analytics
- **App Service Plan**: Consumption (Y1) tier for cost-effective scaling

### Application Features
- **FastAPI Integration**: Modern, fast web framework for building APIs
- **Shopify Integration**: Pre-built webhooks and API client
- **Health Check Endpoints**: Built-in monitoring and status endpoints
- **Comprehensive Testing**: Unit tests with pytest
- **Local Development**: Full local development setup with Azure Functions Core Tools

### Infrastructure as Code
- **Bicep Templates**: Complete infrastructure definitions
- **Parameterized Deployment**: Environment-specific configurations
- **GitHub Actions**: CI/CD pipeline ready to use

## 📁 Project Structure

```
azure-function-app-boilerplate/
├── azure.yaml                 # azd configuration
├── azd-template.json          # Template metadata
├── backend-integration/        # Main application code
│   ├── azure.yaml             # Service-level azd config
│   ├── function_app.py        # Azure Functions entry point
│   ├── pyproject.toml         # Python dependencies
│   ├── infra/                 # Infrastructure as Code
│   │   ├── main.bicep         # Main Bicep template
│   │   ├── main.parameters.json # Deployment parameters
│   │   └── core/              # Modular Bicep templates
│   ├── shopify/               # Shopify integration
│   ├── webapp/                # FastAPI application
│   ├── utils/                 # Shared utilities
│   └── tests/                 # Test suite
└── .github/workflows/         # CI/CD pipelines
```

## 🔧 Configuration

### Environment Variables

The template uses the following environment variables that will be prompted during `azd up`:

- `AZURE_ENV_NAME`: Environment name (becomes resource group name)
- `AZURE_LOCATION`: Azure region (e.g., `eastus`)
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

### Application Settings

Configure your application in `backend-integration/infra/main.parameters.json`:

```json
{
  "environmentName": {"value": "${AZURE_ENV_NAME}"},
  "location": {"value": "${AZURE_LOCATION}"},
  "appSettings": {
    "value": {
      "APP_DOMAIN": "your-domain.com",
      "API_KEY": "your-api-key",
      "SHOPIFY_APP_URL": "your-shopify-app-url",
      "SHOPIFY_API_KEY": "your-shopify-api-key",
      "SHOPIFY_API_SECRET": "your-shopify-api-secret"
    }
  }
}
```

## 🏃‍♂️ Local Development

1. **Rename the integration (optional but recommended):**
   ```bash
   ./rename-integration.sh <APP-NAME>
   # This renames backend-integration/ to <APP-NAME>/ and updates all references
   ```

2. **Install dependencies:**
   ```bash
   cd <APP-NAME>  # or whatever name you chose
   poetry install
   ```

2. **Configure local settings:**
   ```bash
   cp local.settings.json.example local.settings.json
   # Edit local.settings.json with your development values
   ```

3. **Run locally:**
   ```bash
   poetry run func start
   ```

4. **Run tests:**
   ```bash
   poetry run pytest
   ```

## 🚀 Deployment

### Using Azure Developer CLI (Local)

```bash
# Deploy everything (infrastructure + code)
azd up

# Deploy only code changes
azd deploy

# Deploy only infrastructure changes  
azd provision
```

## Azure DevOps Setup

### Prerequisites

Before setting up Azure DevOps integration, you'll need to gather the following information:

- **Azure Subscription ID**: Found in the [Azure Portal Subscriptions page](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2)
- **Azure Tenant ID**: Available after app registration
- **Azure Client ID**: Generated during app registration

### Step-by-Step Setup

#### 1. Get Azure Subscription ID

Navigate to the [Azure Portal Subscriptions page](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2) and copy your subscription ID.

#### 2. Register Azure Application

1. Go to the [Azure App Registrations page](https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Click **"New registration"**
3. Provide a name for your application
4. Select the appropriate account types
5. Click **"Register"**

This will provide you with:
- **AZURE_CLIENT_ID** (Application ID)
- **AZURE_TENANT_ID** (Directory ID)

#### 3. Configure Federated Credentials

1. In your app registration, navigate to **"Certificates & secrets"**
2. Click on **"Federated credentials"** tab
3. Click **"Add credential"**
4. Configure the federated credential with:
   - **Entity type**: GitHub Actions
   - **Repository**: `your-org/your-repo`
   - **Environment**: `backend-integration-dev` (must match your workflow environment)
   - **Branch**: `main` (or your default branch)

> **Important**: The environment name must match exactly with the environment specified in your GitHub workflows. See the [workflow configuration](https://github.com/SatelCreative/azure-function-app-boilerplate/blob/4149c2b6f838b8b2b9ad6a091120674572347ad1/.github/workflows/backend-integration-azure-deploy.yml#L46-L47) for reference.

#### 4. Assign Contributor Role

The registered app needs contributor permissions for your Azure subscription. Run the following command locally:

```bash
az role assignment create \
  --assignee "AZURE_CLIENT_ID" \
  --role "Contributor" \
  --scope "/subscriptions/AZURE_SUBSCRIPTION_ID"
```

**Verification**: To verify the role assignment, run:

```bash
az role assignment list \
  --assignee "AZURE_CLIENT_ID" \
  --scope "/subscriptions/AZURE_SUBSCRIPTION_ID" \
  --output table
```

> **Note**: Make sure you're logged into the correct Azure organization before running these commands.

### Environment Variables

Once the app has been created on Azure, you'll need to add the following environment variables to your GitHub repository variables/secrets:

- `<APP_NAME>_CLIENT_ID`
- `<APP_NAME>_TENANT_ID` 
- `<APP_NAME>_SUBSCRIPTION_ID`
- `<APP_NAME>_ENV_NAME`
- `<APP_NAME>_LOCATION`

This boilerplate provides a production-ready foundation for building Azure Function-based integrations with proper monitoring, deployment pipelines, and infrastructure management.


## 🎯 Customization

### Creating a New Integration

1. **Rename the integration directory:**
   ```bash
   ./rename-integration.sh your-integration-name
   # This script will rename app-integration/ and update all configuration files
   ```

2. **Update configuration files:**
   - Update `azure.yaml` service project path
   - Update `pyproject.toml` project name
   - Update GitHub workflow file paths

3. **Customize the integration code:**
   - Replace Shopify-specific code in `shopify/` directory
   - Update configuration in `utils/config.py`
   - Modify API endpoints in `webapp/main.py`

4. **Update infrastructure parameters:**
   - Modify `infra/main.parameters.json` for your specific needs
   - Add any additional Azure resources in `infra/main.bicep`

### Adding New Azure Resources

1. **Create Bicep modules** in `backend-integration/infra/core/`
2. **Reference them** in `main.bicep`
3. **Add parameters** to `main.parameters.json`
4. **Update app settings** as needed

## 📊 Monitoring

The template includes comprehensive monitoring setup:

- **Application Insights**: Automatic telemetry collection
- **Custom Dashboards**: Pre-configured monitoring dashboards
- **Health Checks**: Built-in health check endpoints
- **Log Analytics**: Centralized logging and querying

Access your monitoring data:
- Application Insights: Azure Portal → Your Function App → Application Insights
- Logs: Azure Portal → Your Function App → Logs
- Metrics: Azure Portal → Your Function App → Metrics

## 🛠️ Troubleshooting

### Common Issues

1. **Deployment fails with permissions error:**
   - Ensure your Azure account has Contributor role on the subscription
   - Check that azd is authenticated: `azd auth login`

2. **Function app not starting:**
   - Check Application Insights logs for detailed error messages
   - Verify all required app settings are configured

3. **Local development issues:**
   - Ensure Azure Functions Core Tools are installed
   - Check that `local.settings.json` is properly configured

