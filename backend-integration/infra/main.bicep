targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Application settings for the Function App')
param appSettings object = {}

@description('Service name for unique resource naming within shared resource group')
param serviceName string = 'api'

// Use the service name for azd identification - each app gets unique service name
// azd expects to find resources tagged with the service name from azure.yaml
var azdServiceName = serviceName

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var serviceResourceToken = toLower(uniqueString(subscription().id, name, serviceName, location))
var tags = { 'azd-env-name': name }

// Create or use existing resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
  tags: tags
}

var prefix = '${name}-${resourceToken}'
var servicePrefix = '${serviceName}-${serviceResourceToken}'

module monitoring './core/monitor/monitoring.bicep' = {
  name: '${serviceName}-monitoring'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    logAnalyticsName: '${servicePrefix}-logworkspace'
    applicationInsightsName: '${servicePrefix}-appinsights'
    applicationInsightsDashboardName: '${servicePrefix}-appinsights-dashboard'
  }
}

module storageAccount 'core/storage/storage-account.bicep' = {
  name: '${serviceName}-storage'
  scope: resourceGroup
  params: {
    name: '${toLower(take(replace(servicePrefix, '-', ''), 17))}storage'
    location: location
    tags: tags
  }
}

module appServicePlan './core/host/appserviceplan.bicep' = {
  name: '${serviceName}-appserviceplan'
  scope: resourceGroup
  params: {
    name: '${servicePrefix}-plan'
    location: location
    tags: tags
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
  }
}

module functionApp 'core/host/functions.bicep' = {
  name: '${serviceName}-function'
  scope: resourceGroup
  params: {
    name: '${servicePrefix}-function-app'
    location: location
    tags: union(tags, { 'azd-service-name': azdServiceName })
    alwaysOn: false
    appSettings: union(
      {
        AzureWebJobsFeatureFlags: 'EnableWorkerIndexing'
      },
      appSettings
    )
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.12'
    storageAccountName: storageAccount.outputs.name
  }
}

module diagnostics 'core/host/app-diagnostics.bicep' = {
  name: '${serviceName}-functions-diagnostics'
  scope: resourceGroup
  params: {
    appName: functionApp.outputs.name
    kind: 'functionapp'
    diagnosticWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
  }
}
