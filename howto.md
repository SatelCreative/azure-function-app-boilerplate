# Azure Function App Boilerplate

Repo to create an azure function app

## 🚀 Getting Started with This Boilerplate

This boilerplate provides a complete Azure Function App setup that can be
customized for specific integrations (e.g., Shopify, Stripe, etc.).

### Step 1: Rename the Integration Directory

The `backend-integration` folder and its references could be renamed to match
your specific integration:

```bash
# Example: For a Shopify integration
mv backend-integration/ shopify-integration/

# Example: For a Stripe integration  
mv backend-integration/ stripe-integration/

# Example: For a Recharge integration
mv backend-integration/ recharge-integration/
```

### Step 2: Update Project Configuration

#### 2.1 Update `pyproject.toml`

In `{your-integration}/pyproject.toml`:

```toml
[project]
name = "your-integration-name"  # Change from "backend-integration"
```

### Step 3: Update Documentation

#### 3.1 Main README

In `{your-integration}/README.md`:

- Change title from `# Backend Integration` to `# Your Integration Name`
- Update app_name reference on line 59 from `"Backend Integration"` to
  `"Your Integration"`

#### 3.2 Infrastructure README

In `{your-integration}/infra/README.md`:

- Update any references to match your integration name

### Step 4: Update GitHub Workflows

#### 4.1 Rename Workflow Files

```bash
# Rename deployment workflow
mv .github/workflows/backend-integration-azure-deploy.yaml .github/workflows/{your-integration}-azure-deploy.yaml

# Rename validation workflow  
mv .github/workflows/backend-integration-azure-bicep-validate.yaml .github/workflows/{your-integration}-azure-bicep-validate.yaml
```

#### 4.2 Update Workflow Content

**In `{your-integration}-azure-deploy.yaml`:**

- Change workflow name to `Deploy {Your Integration} to Azure`
- Update path trigger to `'{your-integration}/**'`
- Update `cd backend-integration` to `cd {your-integration}`

**In `{your-integration}-azure-bicep-validate.yaml`:**

- Update path trigger to `'{your-integration}/**'`
- Update bicep path to `{your-integration}/infra/main.bicep`

### Step 5: Customize Integration Logic

#### 5.1 Update Configuration

In `{your-integration}/utils/config.py` and related config files:

- Update environment variables and settings specific to your integration
- Modify API endpoints and authentication as needed

#### 5.2 Update Integration-Specific Code

In `{your-integration}/shopify/` (or create your own integration folder):

- Replace Shopify-specific code with your integration logic
- Update configuration classes and API calls

### Step 6: Environment Setup

#### 6.1 Azure Environment Variables

Set up your `.azure/{env-name}/.env` file with:

```bash
AZURE_ENV_NAME=your-integration-env
AZURE_LOCATION=eastus
# Add other integration-specific variables
```

#### 6.2 Application Settings

Update `{your-integration}/infra/main.parameters.json` with your integration's
required settings:

- API keys
- Webhook URLs
- Integration-specific configuration

### Quick Checklist ✅

Before deploying your customized integration:

- [ ] Renamed `backend-integration/` directory
- [ ] Updated `pyproject.toml` project name
- [ ] Updated `azure.yaml` service name
- [ ] Renamed and updated both GitHub workflow files
- [ ] Updated README files with correct integration name
- [ ] Customized integration-specific code and configuration
- [ ] Set up Azure environment variables
- [ ] Updated infrastructure parameters

### Example: Complete Shopify Integration Setup

```bash
# 1. Rename directory
mv backend-integration/ shopify-integration/

# 2. Rename workflows
mv .github/workflows/backend-integration-azure-deploy.yaml .github/workflows/shopify-integration-azure-deploy.yaml
mv .github/workflows/backend-integration-azure-bicep-validate.yaml .github/workflows/shopify-integration-azure-bicep-validate.yaml

# 3. Update files (see detailed instructions above)
# 4. Deploy
cd shopify-integration/
azd up
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

This boilerplate provides a production-ready foundation for building Azure
Function-based integrations with proper monitoring, deployment pipelines, and
infrastructure management.
