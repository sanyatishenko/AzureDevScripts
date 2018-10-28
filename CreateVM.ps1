function Create-AzureVM {
    param (
        [string] $Path,
        [pscredential] $Cred

    )
    #Get-AzureRmSubscription
    #$Path = "C:\Projects\AzureDevScripts\AzureVM.json"
    #$Cred = Get-Credential "localadmin"
    $content = Get-Content -Path $Path -Raw 
    $VMJSON = ConvertFrom-Json $content
    foreach ($VM in $VMJSON){
        New-AzureRmVM -ResourceGroupName $VM.ResourceGroup -Location $VM.Location -Name $VM.VMName `
                      -Credential $Cred -ImageName $VM.ImageName -Size $VM.VMSize `
                      -VirtualNetworkName $VM.vNetName -SubnetName $VM.SubNetName 
                      #-PublicIpAddressName $VM.PublicIP
    }
    
}