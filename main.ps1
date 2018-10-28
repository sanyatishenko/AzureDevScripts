Connect-AzureRmAccount
get-AzureRmSubscription
#Select-AzureRmSubscription -Subscription "xxxxxxxxxx-xxxxx-xxxxxx-xxxxxxx-xxxxxxxx"

$resourceGroup = "ToDelResGroup"
$location = "eastus"
$NetConfPath = "C:\Projects\AzureDevScripts\AzureNetwork.json"
$VMConfPath = "C:\Projects\AzureDevScripts\AzureVM.json"

. .\CreateRG.ps1
. .\CreateNetwork.ps1
. .\CreateVM.ps1


Create-ResourceGroup -location $location -resourceGroup $resourceGroup
Create-AzureNetwork -location $location -Path $NetConfPath -ResourceGroup $resourceGroup
Create-AzureVM -Path $VMConfPath -Cred (Get-Credential)