@description('Location')
param location string = resourceGroup().location

@description('Virtual Machine Name')
param vmName string = 'vm-workshop'

@description('Admin Username')
param adminUsername string = 'azureuser'

@secure()
@description('SSH Public Key')
param sshPublicKey string

@description('NIC Resource ID')
param nicId string

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location

  tags: {
    Environment: 'Workshop'
    Application: 'SpringBoot'
  }

  properties: {

    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername

      linuxConfiguration: {
        disablePasswordAuthentication: true

        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }

      customData: base64('''
#cloud-config

package_update: true
package_upgrade: true

packages:
 - openjdk-17-jdk
 - wget
 - curl
 - unzip

runcmd:
 - mkdir -p /opt/workshop
 - echo "Java Installed" > /opt/workshop/setup.txt
 - java -version > /opt/workshop/java-version.txt 2>&1
''')
    }

    storageProfile: {

      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'

        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nicId
        }
      ]
    }
  }
}

output vmId string = vm.id
output vmNameOutput string = vm.name
