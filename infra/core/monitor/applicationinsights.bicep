param name string
param dashboardName string
param location string = resourceGroup().location
param tags object = {}
param logAnalyticsWorkspaceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

module applicationInsightsDashboard 'applicationinsights-dashboard.bicep' = {
  name: 'application-insights-dashboard'
  params: {
    name: dashboardName
    location: location
    applicationInsightsName: applicationInsights.name
  }
}

output appInsightsConnectionString string = applicationInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey
output appInsightsName string = applicationInsights.name
