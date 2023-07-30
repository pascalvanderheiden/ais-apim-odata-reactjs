param name string
param location string = resourceGroup().location
param tags object = {}

module web '../core/host/staticwebapp.bicep' = {
  name: 'staticwebapp'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': name })
  }
}

output SERVICE_WEB_NAME string = web.outputs.swaName
output SERVICE_WEB_URI string = web.outputs.swaUri
output swaHostname string = web.outputs.swaHostname
