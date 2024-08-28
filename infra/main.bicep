targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param basketAPIExists bool
@secure()
param basketAPIDefinition object
param catalogAPIExists bool
@secure()
param catalogAPIDefinition object
param mobileBffShoppingExists bool
@secure()
param mobileBffShoppingDefinition object
param orderProcessorExists bool
@secure()
param orderProcessorDefinition object
param orderingAPIExists bool
@secure()
param orderingAPIDefinition object
param paymentProcessorExists bool
@secure()
param paymentProcessorDefinition object
param webAppExists bool
@secure()
param webAppDefinition object
param webhookClientExists bool
@secure()
param webhookClientDefinition object
param webhooksAPIExists bool
@secure()
param webhooksAPIDefinition object
param eShopAppHostExists bool
@secure()
param eShopAppHostDefinition object

@description('Id of the user or app to assign application roles')
param principalId string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module monitoring './shared/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    location: location
    tags: tags
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
  }
  scope: rg
}

module dashboard './shared/dashboard-web.bicep' = {
  name: 'dashboard'
  params: {
    name: '${abbrs.portalDashboards}${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    location: location
    tags: tags
  }
  scope: rg
}

module registry './shared/registry.bicep' = {
  name: 'registry'
  params: {
    location: location
    tags: tags
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  }
  scope: rg
}

module keyVault './shared/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    tags: tags
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    principalId: principalId
  }
  scope: rg
}

module appsEnv './shared/apps-env.bicep' = {
  name: 'apps-env'
  params: {
    name: '${abbrs.appManagedEnvironments}${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
  }
  scope: rg
}

module basketAPI './app/Basket.API.bicep' = {
  name: 'Basket.API'
  params: {
    name: '${abbrs.appContainerApps}basketapi-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}basketapi-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: basketAPIExists
    appDefinition: basketAPIDefinition
  }
  scope: rg
}

module catalogAPI './app/Catalog.API.bicep' = {
  name: 'Catalog.API'
  params: {
    name: '${abbrs.appContainerApps}catalogapi-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}catalogapi-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: catalogAPIExists
    appDefinition: catalogAPIDefinition
  }
  scope: rg
}

module mobileBffShopping './app/Mobile.Bff.Shopping.bicep' = {
  name: 'Mobile.Bff.Shopping'
  params: {
    name: '${abbrs.appContainerApps}mobilebffs-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}mobilebffs-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: mobileBffShoppingExists
    appDefinition: mobileBffShoppingDefinition
  }
  scope: rg
}

module orderProcessor './app/OrderProcessor.bicep' = {
  name: 'OrderProcessor'
  params: {
    name: '${abbrs.appContainerApps}orderprocess-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}orderprocess-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: orderProcessorExists
    appDefinition: orderProcessorDefinition
  }
  scope: rg
}

module orderingAPI './app/Ordering.API.bicep' = {
  name: 'Ordering.API'
  params: {
    name: '${abbrs.appContainerApps}orderingapi-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}orderingapi-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: orderingAPIExists
    appDefinition: orderingAPIDefinition
  }
  scope: rg
}

module paymentProcessor './app/PaymentProcessor.bicep' = {
  name: 'PaymentProcessor'
  params: {
    name: '${abbrs.appContainerApps}paymentproce-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}paymentproce-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: paymentProcessorExists
    appDefinition: paymentProcessorDefinition
  }
  scope: rg
}

module webApp './app/WebApp.bicep' = {
  name: 'WebApp'
  params: {
    name: '${abbrs.appContainerApps}webapp-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}webapp-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: webAppExists
    appDefinition: webAppDefinition
  }
  scope: rg
}

module webhookClient './app/WebhookClient.bicep' = {
  name: 'WebhookClient'
  params: {
    name: '${abbrs.appContainerApps}webhookclien-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}webhookclien-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: webhookClientExists
    appDefinition: webhookClientDefinition
  }
  scope: rg
}

module webhooksAPI './app/Webhooks.API.bicep' = {
  name: 'Webhooks.API'
  params: {
    name: '${abbrs.appContainerApps}webhooksapi-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}webhooksapi-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: webhooksAPIExists
    appDefinition: webhooksAPIDefinition
  }
  scope: rg
}

module eShopAppHost './app/eShop.AppHost.bicep' = {
  name: 'eShop.AppHost'
  params: {
    name: '${abbrs.appContainerApps}eshopapphos-${resourceToken}'
    location: location
    tags: tags
    identityName: '${abbrs.managedIdentityUserAssignedIdentities}eshopapphos-${resourceToken}'
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    containerAppsEnvironmentName: appsEnv.outputs.name
    containerRegistryName: registry.outputs.name
    exists: eShopAppHostExists
    appDefinition: eShopAppHostDefinition
  }
  scope: rg
}

output AZURE_CONTAINER_REGISTRY_ENDPOINT string = registry.outputs.loginServer
output AZURE_KEY_VAULT_NAME string = keyVault.outputs.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
