@description('Location')
param location string = resourceGroup().location

@secure()
@description('MySQL Administrator Password')
param mysqlAdminPassword string

@secure()
@description('SSH Public Key')
param sshPublicKey string

//
// Network
//
module network './network.bicep' = {
  name: 'network'

  params: {
    location: location
  }
}

//
// Database
//
module database './database.bicep' = {
  name: 'database'

  params: {
    location: location

    administratorPassword: mysqlAdminPassword
  }
}

//
// Compute
//
module compute './compute.bicep' = {
  name: 'compute'

  params: {
    location: location

    nicId: network.outputs.nicId

    sshPublicKey: sshPublicKey
  }
}

//
// Outputs
//
output vnetId string = network.outputs.vnetId

output webSubnetId string = network.outputs.webSubnetId

output dbSubnetId string = network.outputs.dbSubnetId

output publicIpId string = network.outputs.publicIpId

output vmId string = compute.outputs.vmId

output vmName string = compute.outputs.vmNameOutput

output mysqlServerName string = database.outputs.mysqlServerName

output mysqlFqdn string = database.outputs.mysqlFqdn
