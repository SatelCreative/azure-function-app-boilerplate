# Infrastructure

This directory contains the Bicep templates for Azure infrastructure deployment.

## Files

- `main.bicep` - Main infrastructure template
- `main.parameters.json` - Deployment parameters
- `core/` - Modular Bicep templates for different resource types

## Quick Deploy

Use the main deployment script from the project root:

```bash
./deploy.sh <app-name>
```

This handles all infrastructure deployment automatically.

## Manual Deploy

For manual deployment:

```bash
azd up
```

See the main [README.md](../../README.md) for complete deployment instructions and multi-app setup.