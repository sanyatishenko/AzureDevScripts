#Connect-AzureRmAccount

# Variables for common values
$resourceGroup = "ToDelResGroup"
$location = "eastus"

#Network
$vnetAddressSpace = '10.10.10.0/24'
$vnetName = 'ToDelVN'
$subNetAddress = '10.10.10.0/25' 
$subNetName = 'ToDelSubNet2'



#*****************************#
#                             #
#    NETWORK CONFIGURATION    #
#                             #
#*****************************#



$vnet = get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Name $vnetName -ErrorAction Ignore

if (-not ($vnet))
{
    # Create a subnet configuration
    $subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
                    -Name $subNetName `
                    -AddressPrefix $subNetAddress 
    # Create a virtual network
    $vnet = New-AzureRmVirtualNetwork `
                    -ResourceGroupName $resourceGroup `
                    -Location $location `
                    -Name $vnetName `
                    -AddressPrefix $vnetAddressSpace `
                    -Subnet $subnetConfig
} 
else
{
    if (-not (Get-AzureRmVirtualNetworkSubnetConfig -Name $subNetName -VirtualNetwork $vnet -ErrorAction Ignore))
    {
        Add-AzureRmVirtualNetworkSubnetConfig `
                        -Name $subNetName `
                        -VirtualNetwork $vnet `
                        -AddressPrefix $subNetAddress
        Set-AzureRmVirtualNetwork `
                        -VirtualNetwork $vnet
     
    }
                  
}
