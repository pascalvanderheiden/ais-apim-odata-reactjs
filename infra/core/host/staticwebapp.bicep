param name string
param location string = resourceGroup().location
param tags object = {}

param sku object = {
  name: 'Standard'
  size: 'Standard'
}

resource web 'Microsoft.Web/staticSites@2022-03-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': 'web' })
  sku: sku
  properties: {
    provider: 'Custom'
  }
}

output swaName string = web.name
output swaUri string = 'https://${web.properties.defaultHostname}'
output swaHostname string = substring(web.properties.defaultHostname, 0, indexOf(web.properties.defaultHostname, '.'))
