targetScope = 'subscription'
param location string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-psrule-test'
  location: location
  tags: { Env: 'test' }
}

module aciTests '../main.bicep' = {
  scope: resourceGroup
  name: 'aci-tests'
  params: {
    name: 'acitest01'
    image: 'linux-ado-agent'
    imageServer: 'https://crtest01.azurecr.io'
    imageServerUsername: 'user'
    imageServerPassword: 'pass'
    environmentVariables: [
      {
        name: 'AZP_TOKEN'
        secretValue: 'token'
      }
      {
        name: 'AZP_POOL'
        value: 'ais-linux-pool'
      }
    ]
    dnsServers: []
    cpuCores: 1
    memoryInGb: 2
    subnetResourceId: resourceId('Microsoft.Network/VirtualNetworks/subnets', 'vnet-test-01', 'snet-test-01')
  }
}
