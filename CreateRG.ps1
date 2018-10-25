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