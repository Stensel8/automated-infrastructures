/*
This Bicep template deploys the following resources in Azure:

1. A Virtual Network (VNet) with a single subnet:
   - Address space: 10.0.0.0/16
   - Subnet: 10.0.0.0/24

2. A Network Security Group (NSG) with inbound rules for HTTP (port 80) and HTTPS (port 443) traffic.

3. Four Web Servers (Virtual Machines) with:
   - Ubuntu Server 22.04 LTS as the operating system.
   - Standard_B1s as the VM size.
   - Dynamic private IP allocation.
   - Admin credentials provided via parameters.
   - Resource names that include both the base name and the environment.
   - No Public IP addresses (compliant with policy restrictions).

Note: Replace any default values with your secure and preferred settings.
*/

param location string = resourceGroup().location
param baseName string = 'StenWeb'          // Change this to your preferred naming scheme
param adminUsername string               // Supply your admin username (e.g. "sten")
@secure()
param adminPassword string               // Supply your secure admin password
param environment string = 'Testomgeving'  // Environment for resource naming: Testomgeving, Productieomgeving, Ontwikkelomgeving

// Create an array of Web Server names. In this example, four servers are created.
var vmNames = [
  '${baseName}-${environment}-01'
  '${baseName}-${environment}-02'
  '${baseName}-${environment}-03'
  '${baseName}-${environment}-04'
]

// Create Virtual Network (VNet) with a single subnet.
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${baseName}-${environment}-vnet'
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

// Create Network Security Group (NSG) with inbound rules for HTTP and HTTPS traffic.
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: '${baseName}-${environment}-nsg'
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
    ]
  }
}

// Create Network Interfaces (NICs) for each Web Server.
// No Public IP is assigned.
resource networkInterfaces 'Microsoft.Network/networkInterfaces@2021-02-01' = [for (vmName, i) in vmNames: {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
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
// The imageReference uses SKU '22_04-lts-gen2' as required.
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
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
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
