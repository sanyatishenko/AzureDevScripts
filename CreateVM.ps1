function Create-AzureVM {
    param (
        [string] $Path,
        [pscredential] $Cred
    )
    #$Path = "C:\Projects\AzureDevScripts\AzureVM.json"
    #$Cred = Get-Credential "localadmin"
    $content = Get-Content -Path $Path -Raw 
    $VMJSON = ConvertFrom-Json $content
    foreach ($VM in $VMJSON){
        $Location = $VM.Location
        $RGName = $VM.ResourceGroup

        # New VM Configuration
        $VMConfig = New-AzureRMVMConfig -VMName $VM.VMName -VMSize $VM.VMSize

        #! Configuration Boot Disk  # Add for Linux
        $VMConfig = Set-AzureRmVMOSDisk `
                        -VM $VMConfig -Name "$($VM.VMName)_$($VM.OSDisk.DiscName)" `
                        -Windows `
                        -CreateOption "FromImage" `
                        -StorageAccountType $VM.OSDisk.StorageAccountType

        # Configuration Sours Image for Operation System
        $VMConfig = Set-AzureRmVMSourceImage `
                    -VM $VMConfig `
                    -PublisherName $VM.OS.PublisherName `
                    -Offer $VM.OS.Offer `
                    -Skus $VM.OS.Skus `
                    -Version $VM.OS.Version 

        # Configuration Operation System
        $VMConfig = Set-AzureRmVMOperatingSystem `
                    -Windows `
                    -ComputerName $VM.VMName `
                    -Credential $Cred `
                    -VM $VMConfig `
                    -TimeZone $VM.OS.TimeZone 

        # Configuration Network Interfaces
        foreach ($NIC in $VM.NetworkAdapters){
            $vNet = Get-AzureRmVirtualNetwork -ResourceGroupName $RGName -Name $NIC.vNetName
            $SubNetID = $vNet.Subnets | where Name -EQ $NIC.SubNetName | select ID -ExpandProperty ID
            If ($NIC.PublicIP){
                $pip = New-AzureRmPublicIpAddress `
                    -Name "$($VM.VMName)_$($NIC.NicName)_PubIP" `
                    -ResourceGroupName $RGName `
                    -Location $Location `
                    -IpAddressVersion "IPv4" `
                    -AllocationMethod "Dynamic"

                $NewNIC = New-AzureRmNetworkInterface `
                    -Name "$($VM.VMName)_$($NIC.NicName)" `
                    -ResourceGroupName $RGName `
                    -Location $Location `
                    -PublicIpAddressId $pip.Id `
                    -SubnetId $SubNetID    
            }# End IF PublicIP
            else {
                $NewNIC = New-AzureRmNetworkInterface `
                    -Name "$($VM.VMName)_$($NIC.NicName)" `
                    -ResourceGroupName $RGName `
                    -Location $Location `
                    -SubnetId $SubNetID 
            } # End Else of IF PublicIP
            
            # Add Network Interface to VM Configuration
            If ($NIC.Primary){
                $VMConfig = Add-AzureRmVMNetworkInterface -Id $NewNIC.Id -VM $VMConfig -Primary
            } #End if Primary interface
            else{
                $VMConfig = Add-AzureRmVMNetworkInterface -Id $NewNIC.Id -VM $VMConfig
            } #End else if Primary interface
            

        } # End ForEach Network Interfaces
        
        # Configuration Data Disks
        ForEach ($DISK in $VM.DataDisk){
            $DiskConfig = New-AzureRmDiskConfig `
                        -Location $Location `
                        -DiskSizeGB $DISK.DiskSizeGB `
                        -CreateOption "Empty"
            $NewDisk = New-AzureRmDisk `
                        -ResourceGroupName $RGName `
                        -DiskName "$($VM.VMName)_$($DISK.DiskName)" `
                        -Disk $DiskConfig
            $VMConfig = add-AzureRmVMDataDisk `
                        -VM $VMConfig `
                        -ManagedDiskId $NewDisk.id `
                        -Name "$($VM.VMName)_$($DISK.DiskName)" `
                        -Lun $DISK.Lun `
                        -CreateOption "Attach" `
                        -StorageAccountType $DISK.StorageAccountType
        } # End of ForEach Data Disks

        $VMConfig = Set-AzureRmVMBootDiagnostics -VM $VMConfig -Disable 

        # Create Virtual Machine
        New-AzureRmVM -ResourceGroupName  $RGName -Location $Location -VM $VMConfig 

    } # End ForEach VM
    
}