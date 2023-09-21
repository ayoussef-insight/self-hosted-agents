@description('Name for the container group')
param name string
@description('Location for all resources.')
param location string = resourceGroup().location
@description('Container image server url')
param imageServer string
@description('Container image server Username')
param imageServerUsername string
@secure()
@description('Container image server Password.')
param imageServerPassword string
@description('Container image to deploy.')
param image string
@description('(Optional. VNet Subnet Resource Id to deploy the container instance to.')
param subnetResourceId string = ''
@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1
@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2
@description('OS type')
@allowed(['Linux', 'Windows'])
param osType string = 'Linux'
@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'
@description('Number of linux container instances deploy. Note: Multi-container groups currently support only Linux containers. For Windows containers, Azure Container Instances only supports deployment of a single container instance.')
param instances int = 1
@description('Container environment variables. Array of name, value|secureValue')
param environmentVariables array
@description('Resource tags')
param tags object = { Application: 'self-hosted' }
@description('Custom DNS servers to use for private DNS. Array of strings holding IP address of DNS servers.')
param dnsServers array

var osAbbreviation = osType == 'Linux' ? 'lnx' : 'win'
var containerPrefix = 'selfhosted-${osAbbreviation}-'

var envVariables = [for e in environmentVariables: {
  name: e.name
  value: contains(e, 'value') ? e.value : null
  secureValue: contains(e, 'secureValue') ? e.secureValue : null
}]

resource containerGroupResource 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    containers: [for index in range(0, instances): {
      name: '${containerPrefix}${padLeft(index + 1, 3, '0')}'
      properties: {
        image: '${imageServer}/${image}'
        environmentVariables: concat(envVariables, [
            {
              name: 'NAME'
              value: '${containerPrefix}${padLeft(index + 1, 2, '0')}'
            }
          ])
        resources: {
          requests: {
            cpu: cpuCores
            memoryInGB: memoryInGb
          }
        }
      }
    }]
    dnsConfig: empty(dnsServers) ? null : {
      nameServers: dnsServers
    }
    imageRegistryCredentials: [
      {
        server: imageServer
        username: imageServerUsername
        password: imageServerPassword
      }
    ]
    osType: osType
    restartPolicy: restartPolicy
    subnetIds: empty(subnetResourceId) ? [] : [
      {
        id: subnetResourceId
      }
    ]
  }
}
