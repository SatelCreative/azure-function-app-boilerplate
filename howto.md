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

This boilerplate provides a production-ready foundation for building Azure
Function-based integrations with proper monitoring, deployment pipelines, and
infrastructure management.
