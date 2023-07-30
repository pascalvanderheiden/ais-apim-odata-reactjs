param name string
param location string = resourceGroup().location

@description('Resource name to uniquely identify the API Management service instance')
@minLength(1)
param apimName string

@description('Resource name to uniquely identify the Static Web App')
@minLength(1)
param swaName string

resource apimService 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apimName
}

resource web 'Microsoft.Web/staticSites@2022-03-01' existing = {
  name: swaName
}

resource swaLinkedBackend 'Microsoft.Web/staticSites/linkedBackends@2022-03-01' = {
  name: name
  kind: 'API management'
  parent: web
  properties: {
    backendResourceId: apimService.id
    region: location
  }
}
