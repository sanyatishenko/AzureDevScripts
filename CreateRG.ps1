##########################################################
#
#   Function create Resource Group in Azure
#   Requirement parameters: 
#   $location Azure location
#   $ResourceGroup Azure resource group name
#
#   Before runing function, you must runnin commands:
#   Connect-AzureRmAccount
#   Set-AzureRmSubscription
#
##########################################################
function Create-ResourceGroup {
    param (
        [string]$resourceGroup,
        [string]$location
    )
    # Create a resource group
    if (-not (get-AzureRmResourceGroup -Name $resourceGroup -ErrorAction Ignore))
    {
        New-AzureRmResourceGroup -Name $resourceGroup -Location $location
        Write-Host "Created resource group: $resourceGroup"
    } 
    else 
    {
        Write-Host "Selected resource group: $resourceGroup"
    }
}
