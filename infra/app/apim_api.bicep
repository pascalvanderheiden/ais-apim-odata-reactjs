param apimName string
param swaHostname string
param keyVaultEndpoint string
param sapKeyVaultSecretName string
param managedIdentityName string
param sapUri string

var sapApiKeyNamedValue = 'sap-apikey'
var sapApiBackendId = 'sap-backend'

resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
}

resource apimLogger 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' existing = {
  name: 'appinsights-logger'
  parent: apimService
}

resource swaProduct 'Microsoft.ApiManagement/service/products@2023-03-01-preview' existing = {
  name: swaHostname
  parent: apimService
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentityName
}

resource apimSapApi 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  name: 'api-business-partner'
  parent: apimService
  properties: {
    path: 'api/sapbp' //Note: the path must start with 'api/', otherwise the Static Web App won't be able to link this API.
    displayName: 'SAP Business Partner API'
    subscriptionRequired: true
    format: 'odata-link'
    value:  'https://raw.githubusercontent.com/pascalvanderheiden/ais-apim-odata-reactjs/main/infra/app/odata/API_BUSINESS_PARTNER.edmx'
    protocols: [
      'https'
      'http'
    ]
  }
}

resource apimSapBackend 'Microsoft.ApiManagement/service/backends@2023-03-01-preview' = {
  name: sapApiBackendId
  parent: apimService
  properties: {
    description: sapApiBackendId
    url: sapUri
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

resource apimSapApiKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2023-03-01-preview' = {
  name: sapApiKeyNamedValue
  parent: apimService
  properties: {
    displayName: sapApiKeyNamedValue
    secret: true
    keyVault:{
      secretIdentifier: '${keyVaultEndpoint}secrets/${sapKeyVaultSecretName}'
      identityClientId: apimService.identity.userAssignedIdentities[managedIdentity.id].clientId
    }
  }
}

resource apiPolicies 'Microsoft.ApiManagement/service/apis/policies@2023-03-01-preview' = {
  name: 'policy'
  parent: apimSapApi
  properties: {
    value: loadTextContent('./policies/api_policy.xml')
    format: 'rawxml'
  }
  dependsOn: [
    apimSapBackend
    apimSapApiKeyNamedValue
  ]
}

resource linkDemoConferenceApiToSwaProduct 'Microsoft.ApiManagement/service/products/apis@2022-08-01' = {
  name: apimSapApi.name
  parent: swaProduct
}

resource apiDiagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2023-03-01-preview' = {
  name: 'applicationinsights'
  parent: apimSapApi
  properties: {
    alwaysLog: 'allErrors'
    backend: {
      request: {
        body: {
          bytes: 1024
        }
      }
      response: {
        body: {
          bytes: 1024
        }
      }
    }
    frontend: {
      request: {
        body: {
          bytes: 1024
        }
      }
      response: {
        body: {
          bytes: 1024
        }
      }
    }
    httpCorrelationProtocol: 'W3C'
    logClientIp: true
    loggerId: apimLogger.id
    metrics: true
    sampling: {
      percentage: 100
      samplingType: 'fixed'
    }
    verbosity: 'verbose'
  }
}

output SERVICE_API_URI string = '${apimService.properties.gatewayUrl}/${apimSapApi.properties.path}'
