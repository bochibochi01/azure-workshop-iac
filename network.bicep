@description('Location')
param location string = resourceGroup().location

@description('Virtual Network Name')
param vnetName string = 'vnet-workshop'

@description('Web Subnet Name')
param webSubnetName string = 'subnet-web'

@description('DB Subnet Name')
param dbSubnetName string = 'subnet-db'

@description('NSG Name')
param nsgName string = 'nsg-workshop'

@description('Public IP Name')
param publicIpName string = 'pip-workshop'

@description('NIC Name')
param nicName string = 'nic-workshop'

//
// Network Security Group
//
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location

  properties: {
    securityRules: [
      {
        name: 'Allow-SSH'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Allow-App8080'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '8080'
        }
      }
    ]
  }
}

//
// Virtual Network
//
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: dbSubnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

//
// Public IP
//
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//
// NIC
//
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              vnet.name,
              webSubnetName
            )
          }

          publicIPAddress: {
            id: publicIp.id
          }

          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output nicId string = nic.id
output publicIpId string = publicIp.id
