targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@minLength(1)
@maxLength(64)
@description('API Key for SAP (you can get this from https://api.sap.com/api/API_BUSINESS_PARTNER/tryout).')
@secure()
param sapApiKey string

@minLength(1)
@maxLength(300)
@description('SAP Uri (you can get this from https://api.sap.com/api/API_BUSINESS_PARTNER/tryout).')
param sapEndpoint string = 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER'


//Leave blank to use default naming conventions
param resourceGroupName string = ''
param keyVaultName string = ''
param identityName string = ''
param apimServiceName string = ''
param logAnalyticsName string = ''
param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param webServiceName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }
var sapApiKeySecretName = 'sap-api-key'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module managedIdentity './core/security/managed-identity.bicep' = {
  name: 'managed-identity'
  scope: rg
  params: {
    name: !empty(identityName) ? identityName : '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    location: location
    tags: tags
  }
}

module keyVault './core/security/key-vault.bicep' = {
  name: 'key-vault'
  scope: rg
  params: {
    name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
    managedIdentityName: managedIdentity.outputs.managedIdentityName
  }
}

module sapKeyVaultSecret './core/security/keyvault-secret.bicep' = {
  name: 'sap-keyvault-secret'
  scope: rg
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    name: sapApiKeySecretName
    secretValue: sapApiKey
  }
}

module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

module apim './core/gateway/apim.bicep' = {
  name: 'apim'
  scope: rg
  params: {
    name: !empty(apimServiceName) ? apimServiceName : '${abbrs.apiManagementService}${resourceToken}'
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    managedIdentityName: managedIdentity.outputs.managedIdentityName
  }
}

// The application frontend
module web './app/web.bicep' = {
  name: 'web'
  scope: rg
  params: {
    name: !empty(webServiceName) ? webServiceName : '${abbrs.webStaticSites}${resourceToken}'
    location: location
    tags: tags
  }
}

// Configures the API in the Azure API Management (APIM) service
module apimApi './app/apim_api.bicep' = {
  name: 'apim-apis'
  scope: rg
  params: {
    apimName: apim.outputs.apimName
    swaHostname: web.outputs.swaHostname
    keyVaultEndpoint: keyVault.outputs.keyVaultEndpoint
    sapKeyVaultSecretName: sapApiKeySecretName
    managedIdentityName: managedIdentity.outputs.managedIdentityName
    sapUri: sapEndpoint
  }
  dependsOn: [
    webApimLink
  ]
}

// Configures the link between the web frontend and the APIM service
module webApimLink './app/web_apim_link.bicep' = {
  name: 'web-apim-link'
  scope: rg
  params: {
    name: 'backend1'
    location: location
    apimName: apim.outputs.apimName
    swaName: web.outputs.SERVICE_WEB_NAME
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output APIM_NAME string = apim.outputs.apimName
output REACT_APP_API_BASE_URL string = apimApi.outputs.SERVICE_API_URI
output REACT_APP_WEB_BASE_URL string = web.outputs.SERVICE_WEB_URI
