#Connect-AzureRmAccount
Select-AzureRmSubscription -Subscription "8f87f15a-2f4b-4459-9410-315180be4dea"

$resourceGroup = "ToDelResGroup"
$location = "eastus"
$Path = "C:\Projects\AzureDevScripts\AzureNetwork.json"
#############################################################################
#                             
#   Function create vNet and subnet in Azure    
#   Requirement parameters: 
#   $Path to the network configuration file
#   $location Azure location
#   $ResourceGroup Azure resource group name
#
#   Before runing function, you must runnin commands:
#   Connect-AzureRmAccount
#   Set-AzureRmSubscription
#                             
#
################################################################################

function Create-AzureNetwork {
    Param(
        [string]$Path,
        [string]$location,
        [string]$ResourceGroup
    )

    $content = Get-Content -Path $Path -Raw 
    $NetJSON = ConvertFrom-Json $content
    
    $vnetName = $NetJSON.vNetName
    $vnetAddressSpace = $NetJSON.vNetCIDR
    
    $vnet = get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Name $vnetName -ErrorAction Ignore

    if (-not ($vnet)){
            # Create a virtual network
            $vnet = New-AzureRmVirtualNetwork `
                            -ResourceGroupName $resourceGroup `
                            -Location $location `
                            -Name $vnetName `
                            -AddressPrefix $vnetAddressSpace                         
        } 
    else {
            Write-Host "vNet $vnetName alredy exist" -ForegroundColor DarkMagenta
        } #End If vNet Create
    
    foreach ($SubNet in $NetJSON.vNetSubnets) {
        if (-not (Get-AzureRmVirtualNetworkSubnetConfig -Name $SubNet.SubNetName -VirtualNetwork $vnet -ErrorAction Ignore)){
            Write-Host "Create SubNet $($SubNet.SubNetName)" -ForegroundColor DarkMagenta
            Add-AzureRmVirtualNetworkSubnetConfig `
                            -Name $SubNet.SubNetName `
                            -VirtualNetwork $vnet `
                            -AddressPrefix $SubNet.SubNetCIDR
            Set-AzureRmVirtualNetwork `
                            -VirtualNetwork $vnet
     
        } 
        else {
                Write-Host "SubNet $($SubNet.SubNetName) alredy exist" -ForegroundColor DarkMagenta
            }
    } # End ForEach vNetSubnets
} #End Function Create-AzureNetwork

Create-AzureNetwork -Path $Path -ResourceGroup $resourceGroup -location $location