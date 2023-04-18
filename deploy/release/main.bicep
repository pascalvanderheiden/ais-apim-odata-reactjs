targetScope = 'resourceGroup'

@minLength(3)
@maxLength(11)
param namePrefix string
param location string
param swaRepositoryUrl string
@secure()
param swaTokenParam string
@secure()
param apiUsername string
@secure()
param apiPassword string

param apimName string
param appInsightsName string

// Create Static Web App
module swaModule '../release/swa.bicep' = {
  name: 'swaDeploy'
  params: {
    namePrefix: namePrefix
    location: location
    repositoryUrl: swaRepositoryUrl
    tokenParam: swaTokenParam
    apimName: apimName
  }
}

// Deploy APIs to API Management
module apimModule '../release/apim_apis.bicep' = {
  name: 'apisDeploy'
  params: {
    apimName: apimName
    appInsightsName: appInsightsName
    swaHostname: swaModule.outputs.swaHostname
    apiUsername: apiUsername
    apiPassword: apiPassword
  }
  dependsOn:[
    swaModule
  ]
}
