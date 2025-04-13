/*
This Bicep template deploys the following resources in Azure:

1. A Virtual Network (VNet) with a single subnet:
   - Address space: 10.0.0.0/16
   - Subnet: 10.0.0.0/24

2. A Network Security Group (NSG) with inbound rules to allow HTTP (port 80), HTTPS (port 443) and SSH (port 22) traffic.

3. Public IP addresses for each virtual machine, dynamically allocated.

4. Network Interfaces (NICs) for each virtual machine, associated with the NSG and VNet subnet.

5. Three Virtual Machines (VMs) with:
   - Ubuntu Server 22.04 LTS as the operating system.
   - Standard_B1s as the VM size.
   - Dynamic private and public IP allocation.
   - Admin credentials provided via parameters.

Note: Replace any default values with your secure and preferred settings.
*/

param location string = resourceGroup().location
param baseName string = 'StenWeb'          // You can change this to your preferred naming scheme
param adminUsername string                 // Supply your admin username (e.g. "sten")
@secure()
param adminPassword string                 // Supply your secure admin password

// Create an array of VM names. In this example, three VMs are created.
var vmNames = [
  '${baseName}01'
  '${baseName}02'
  '${baseName}03'
]

// Create Virtual Network (VNet) with a single subnet.
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${baseName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Create Network Security Group (NSG) with inbound rules.
// Added SSH rule to allow access to port 22.
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-HTTPS'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-SSH'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Create Public IP addresses for each VM (SKU Basic, dynamic allocation).
resource publicIpAddresses 'Microsoft.Network/publicIPAddresses@2021-02-01' = [for vmName in vmNames: {
  name: '${vmName}-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}]

// Create Network Interfaces (NICs) for each VM, associate with the VNet subnet and NSG.
resource networkInterfaces 'Microsoft.Network/networkInterfaces@2021-02-01' = [for (vmName, i) in vmNames: {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddresses[i].id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}]

// Create Virtual Machines using the Ubuntu Server 22.04 LTS image.
resource virtualMachines 'Microsoft.Compute/virtualMachines@2021-03-01' = [for (vmName, i) in vmNames: {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
        }
      ]
    }
  }
}]
