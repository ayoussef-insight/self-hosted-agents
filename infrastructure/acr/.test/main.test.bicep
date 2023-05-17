targetScope = 'subscription'
param location string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-psrule-test'
  location: location
  tags: { Env: 'test'}
}

module acrTests '../main.bicep' = {
  scope: resourceGroup
  name: 'acr-tests'
  params: {
    acrName: 'crtest01'
    acrSku: 'Premium'
  }
}
