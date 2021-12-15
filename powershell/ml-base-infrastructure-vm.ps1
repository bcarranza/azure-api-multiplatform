<#
    .Description
    This a function mainly to create vms; this script is available from : https://docs.microsoft.com/en-us/powershell/module/az.compute/new-azvm?view=azps-7.0.0 
    execution: ./ml-base-infrastructure-vm.ps1 -vm_local_admin_user "mluseradmin" -vm_local_admin_pass "Th3P@ssw0rd01" -vm_location "EastUS" -vm_subnetid "xx" -rsg_name "ml-resourcegroup" -vm_name="xxx" -dns_name "xxx" -public_ip "true" -public_ip_name "xxxx"
    author: bayron.carranza
    improvements this file needs: validations of existing resources

#>


param(
    [string]$vm_local_admin_user = "",
    [string]$vm_local_admin_pass = "",
    [string]$vm_location = "",
    [string]$vm_subnet_id = "",
    [string]$rsg_name = "",
    [string]$vm_name = "",
    [string]$dns_name = "",
    [Boolean]$public_ip= "",
    [string]$public_ip_name= ""
    )
## VM Account
# Credentials for Local Admin account you created in the sysprepped (generalized) vhd image
$VMLocalAdminUser = $vm_local_admin_user
$VMLocalAdminSecurePassword = ConvertTo-SecureString $vm_local_admin_pass -AsPlainText -Force
## Azure Account
$LocationName = $vm_location
$ResourceGroupName = $rsg_name

## VM. (point of improvement: this structure as parameter)
$OSDiskName = "MyClient"
$ComputerName = "MyClientVM"
$OSDiskUri = "https://Mydisk.blob.core.windows.net/disks/MyOSDisk.vhd"
$SourceImageUri = "https://Mydisk.blob.core.windows.net/vhds/MyOSImage.vhd"
$VMName = $vm_name

# Modern hardware environment with fast disk, high IOPs performance.
# Required to run a client VM with efficiency and performance
$VMSize = "Standard_DS3"
$OSDiskCaching = "ReadWrite"
$OSCreateOption = "FromImage"

## Networking
$DNSNameLabel = $dns_name # mydnsname.westus.cloudapp.azure.com
$NICNamePrefix = "ml_nic_bastion_"
$NICName = $NICNamePrefix + $vm_name
$PublicIPAddressName = $public_ip_name

Write-Host "Preparing components, public _ip? : " $public_ip
Write-Host "Subneting id : " $vm_subnet_id

if($public_ip) {
    Write-Host "Command PIP: New-AzPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic"
    $PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic
    
    Write-Host "Command NIC: New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $vm_subnet_id -PublicIpAddressId $PIP.Id"
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $vm_subnet_id -PublicIpAddressId $PIP.Id
 }else {
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $vm_subnetid
 }

Write-Host "Creating vmname-> $VMName "
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);
$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -SourceImageUri $SourceImageUri -Caching $OSDiskCaching -CreateOption $OSCreateOption -Windows

New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose

Write-Host "VM created succesfully"