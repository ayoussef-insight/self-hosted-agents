@description('Specifies the location for resources.')
param location string = resourceGroup().location
@description('Azure Container Registry name')
param acrName string
@description('Azure Container Registry SKU')
param acrSku string

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}

output resourceId string = acrResource.id
