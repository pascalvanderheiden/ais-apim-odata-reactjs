param apimName string
param appInsightsName string
@secure()
param swaHostname string
@secure()
param apiUsername string
@secure()
param apiPassword string

resource apiManagement 'Microsoft.ApiManagement/service@2022-08-01' existing = {
  name: apimName
}

resource apiManagementLogger 'Microsoft.ApiManagement/service/loggers@2022-08-01' existing = {
  name: appInsightsName
  parent: apiManagement
}

resource swaProduct 'Microsoft.ApiManagement/service/products@2022-08-01' existing = {
  name: swaHostname
  parent: apiManagement
}

resource apimApi 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  name: 'api-business-partner'
  parent: apiManagement
  properties: {
    path: 'api/sapbp' //Note: the path must start with 'api/', otherwise the Static Web App won't be able to link this API.
    apiRevision: '1'
    displayName: 'SAP Business Partner API'
    subscriptionRequired: true
    format: 'openapi+json-link'
    value:  'https://raw.githubusercontent.com/pascalvanderheiden/ais-apim-odata-reactjs/main/deploy/release/apim/odata/API_BUSINESS_PARTNER%20PM4.openapi%2Bjson.json'
    protocols: [
      'https'
    ]
  }
}

resource apiUsernameNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: 'apiusernamesap'
  parent: apiManagement
  properties: {
    displayName: 'apiUsername'
    value: apiUsername
  }
}

resource apiPasswordNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: 'apipasswordsap'
  parent: apiManagement
  properties: {
    displayName: 'apiPassword'
    secret: true
    value: apiPassword
  }
}

resource apiPolicies 'Microsoft.ApiManagement/service/apis/policies@2022-08-01' = {
  name: 'policy'
  parent: apimApi
  properties: {
    value: loadTextContent('./apim/policies/api_policy.xml')
    format: 'rawxml'
  }
}

resource linkDemoConferenceApiToSwaProduct 'Microsoft.ApiManagement/service/products/apis@2022-08-01' = {
  name: apimApi.name
  parent: swaProduct
}

resource apiMonitoring 'Microsoft.ApiManagement/service/apis/diagnostics@2022-08-01' = {
  name: 'applicationinsights'
  parent: apimApi
  properties: {
    alwaysLog: 'allErrors'
    loggerId: apiManagementLogger.id  
    logClientIp: true
    httpCorrelationProtocol: 'W3C'
    verbosity: 'verbose'
    operationNameFormat: 'Url'
  }
}
