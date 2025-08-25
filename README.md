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
   azd init --template <your-github-username>/azure-function-app-boilerplate
   cd your-project-name
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

1. **Install dependencies:**
   ```bash
   cd backend-integration
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

### Using Azure Developer CLI (Recommended)

```bash
# Deploy everything (infrastructure + code)
azd up

# Deploy only code changes
azd deploy

# Deploy only infrastructure changes  
azd provision
```

### Using GitHub Actions

The template includes GitHub Actions workflows for CI/CD:

1. **Set up repository secrets:**
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET` 
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

2. **Workflows will automatically:**
   - Validate Bicep templates on PR
   - Deploy to staging on merge to main
   - Deploy to production on release

## 🎯 Customization

### Creating a New Integration

1. **Rename the backend-integration directory:**
   ```bash
   mv backend-integration/ my-integration/
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

### Getting Help

- [Azure Functions Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**Happy coding!** 🎉