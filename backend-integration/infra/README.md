# Infrastructure Deployment

## Quick Start

Deploy Azure resources using Azure Developer CLI:

```bash
azd up
```

This command will:

- Create a resource group with the name specified in `AZURE_ENV_NAME`
- Deploy all Azure resources defined in the Bicep templates
- Configure the Function App with settings from `main.parameters.json`

## Resources Created

- **Resource Group**: Named after your environment (e.g., `my-env`)
- **Function App**: Python 3.12 runtime on consumption plan
- **Storage Account**: Required for Azure Functions
- **Application Insights**: Monitoring and logging
- **Log Analytics Workspace**: Centralized logging
- **App Service Plan**: Consumption (Y1) tier

## Configuration

App settings are defined in `main.parameters.json`:

- `APP_DOMAIN`: Application domain
- `API_KEY`: API authentication key
- `SHOPIFY_*`: Shopify integration credentials

## Environment Variables

Run `azd up` and follow the prompt to set the below:

- `AZURE_ENV_NAME`: Environment name (becomes resource group name)
- `AZURE_LOCATION`: Azure region (e.g., `eastus`)
- `AZURE_SUBSCRIPTION_ID`: Azure subscription id

Please beware that the above variables will be used to form the globally unique
azure function app name.
