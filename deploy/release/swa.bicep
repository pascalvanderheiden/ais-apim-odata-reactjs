@minLength(3)
@maxLength(11)
param namePrefix string
param location string = resourceGroup().location

param repositoryUrl string
@secure()
param tokenParam string
param apimName string

var uniqueSwaName = '${namePrefix}${uniqueString(resourceGroup().id)}-swa'
var sku  = 'Standard'

resource apiManagement 'Microsoft.ApiManagement/service@2022-08-01' existing = {
    name: apimName
  }

resource swa_resource 'Microsoft.Web/staticSites@2022-03-01' = {
    name: uniqueSwaName
    location: location
    properties: {
        branch: 'main'
        repositoryToken: tokenParam
        repositoryUrl: repositoryUrl
        buildProperties: {
            appLocation: './deploy/release/app/react-odata-app'
            apiLocation: '' //Note: important to set this to an empty string, otherwise the linking won't work!
        }
    }
    sku: {
        name: sku
        size: sku
    }
}

resource swa_linkedBackend 'Microsoft.Web/staticSites/linkedBackends@2022-03-01' = {
    name: 'backend1'
    kind: 'API management'
    parent: swa_resource
    properties: {
      backendResourceId: apiManagement.id
      region: location
    }
}

output swaName string = swa_resource.name
output swaHostname string = substring(swa_resource.properties.defaultHostname, 0, indexOf(swa_resource.properties.defaultHostname, '.'))

