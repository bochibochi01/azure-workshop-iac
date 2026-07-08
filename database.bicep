@description('Location')
param location string = resourceGroup().location

@description('MySQL Server Name')
param mysqlServerName string = 'mysql-workshop-demo'

@description('Administrator Username')
param administratorLogin string = 'adminuser'

@secure()
@description('Administrator Password')
param administratorPassword string

@description('Database Name')
param databaseName string = 'workshopdb'

//
// Azure Database for MySQL Flexible Server
//
resource mysqlServer 'Microsoft.DBforMySQL/flexibleServers@2023-12-30' = {
  name: mysqlServerName
  location: location

  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }

  tags: {
    Environment: 'Workshop'
    Application: 'SpringBoot'
  }

  properties: {

    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword

    version: '8.0.21'

    storage: {
      storageSizeGB: 20
      autoGrow: 'Enabled'
    }

    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }

    network: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

//
// Database
//
resource workshopDatabase 'Microsoft.DBforMySQL/flexibleServers/databases@2023-12-30' = {
  parent: mysqlServer
  name: databaseName

  properties: {
    charset: 'utf8mb4'
    collation: 'utf8mb4_unicode_ci'
  }
}

//
// Firewall Rule
// Demo用
//
resource allowAllAzure 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-12-30' = {
  parent: mysqlServer
  name: 'AllowAll'

  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

//
// Outputs
//
output mysqlServerId string = mysqlServer.id

output mysqlServerName string = mysqlServer.name

output mysqlFqdn string = mysqlServer.properties.fullyQualifiedDomainName

output databaseNameOutput string = databaseName
