param logAnalyticsName string
param applicationInsightsName string
param applicationInsightsDashboardName string
param location string = resourceGroup().location
param tags object = {}

module logAnalytics 'loganalytics.bicep' = {
  name: 'log-analytics'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

module applicationInsights 'applicationinsights.bicep' = {
  name: 'application-insights'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    dashboardName: applicationInsightsDashboardName
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

output applicationInsightsConnectionString string = applicationInsights.outputs.appInsightsConnectionString
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.appInsightsInstrumentationKey
output applicationInsightsName string = applicationInsights.outputs.appInsightsName
output logAnalyticsWorkspaceId string = logAnalytics.outputs.id
output logAnalyticsWorkspaceName string = logAnalytics.outputs.name
