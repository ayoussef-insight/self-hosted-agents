@description('Specifies the location for resources.')
param location string = resourceGroup().location
@description('Azure Container Registry name')
param acrName string
@description('Azure Container Registry SKU')
param acrSku string
@description('Resource tags')
param tags object = { Application: 'self-hosted' }

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
    policies: acrSku == 'Premium' ? {
      quarantinePolicy: {
        status: 'enabled'
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 30
      }
    } : {}
  }
}

output resourceId string = acrResource.id
