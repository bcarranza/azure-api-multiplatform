<#
    .Description
    This function create infrastructure base like : 1 resource group , azure insight, vault, 4 NSG (Networking Subnet groups), 1 database , 1 vm as bastion.
    execution: ./ml-base-infrastructure.ps1 -suscription_name "Visual Studio Professional" -rsg_name "ml-resourcegroup" -rsg_location "EastUS" -vnet_name "ml-vnet" -vnet_addressprefix "10.0.0.0/16" -subnet1_name "ml-subnet-1" -subnet1_addressprefix "10.0.1.0/24" -subnet2_name "ml-subnet-2" -subnet2_addressprefix "10.0.2.0/24" -subnet3_name "ml-subnet-3" -subnet3_addressprefix "10.0.3.0/24" -subnet4_name "ml-subnet-4" -subnet4_addressprefix "10.0.4.0/24" -insight_name "ml-az-insight" -vault_name "ml-az-vault" -bastion_name "ml-bastion" -db_name "ml-db" db_object_name "ml-db-multi" -db_user "mluser" -db_pass "Th3P@ssw0rd01"
    remove all resources in RSG: Remove-AzResourceGroup -Name $rsg_name -Force
    author: bayron.carranza
#>
param(
    [string]$suscription_name = "",
    [string]$rsg_name = "", 
    [string]$rsg_location = "",
    [string]$vnet_name = "",
    [string]$vnet_addressprefix = "",
    [string]$subnet1_name = "",
    [string]$subnet1_addressprefix = "",
    [string]$subnet2_name = "",
    [string]$subnet2_addressprefix = "",
    [string]$subnet3_name = "",
    [string]$subnet3_addressprefix = "",
    [string]$subnet4_name = "",
    [string]$subnet4_addressprefix = "",
    [string]$insight_name = "", 
    [string]$vault_name = "",
    [string]$bastion_name = "",
    [string]$db_name = "",
    [string]$db_object_name = "",
    [string]$db_user = "",
    [string]$db_pass = ""
    )

    #connect azure account 
    Write-Host "Conecting to azure account"
    Connect-AzAccount

    #set suscription 
    Write-Host "Conecting to azure suscription: " $suscription_name
    Set-AzContext $suscription_name
    
    #create resource group
    Write-Host "Creating azure resource group: " $rsg_name
    $rg = @{
        Name = $rsg_name
        Location = $rsg_location
    }
    New-AzResourceGroup @rg

    #create vnet
    Write-Host "Creating vnet: " $rsg_name
    $vnet = @{
        Name = $vnet_name
        ResourceGroupName = $rsg_name
        Location = $rsg_location
        AddressPrefix = $vnet_addressprefix
    }
    $virtualNetwork = New-AzVirtualNetwork @vnet

    #create subnet 1
    Write-Host "Creating subnet 1: " $subnet1_name
    $subnet1 = @{
        Name = $subnet1_name
        VirtualNetwork = $virtualNetwork
        AddressPrefix = $subnet1_addressprefix 
    }
    $subnetConfig1 = Add-AzVirtualNetworkSubnetConfig @subnet1
    
    #associate subnet to vnet
    $virtualNetwork | Set-AzVirtualNetwork

    #create subnet 2
    Write-Host "Creating subnet 2: " $subnet2_name
    $subnet2 = @{
        Name = $subnet2_name
        VirtualNetwork = $virtualNetwork
        AddressPrefix = $subnet2_addressprefix 
    }
    $subnetConfig2 = Add-AzVirtualNetworkSubnetConfig @subnet2

    #associate subnet to vnet
    $virtualNetwork | Set-AzVirtualNetwork

    #create subnet 3
    Write-Host "Creating subnet 3: " $subnet3_name
    $subnet3 = @{
        Name = $subnet3_name
        VirtualNetwork = $virtualNetwork
        AddressPrefix = $subnet3_addressprefix 
    }
    $subnetConfig3 = Add-AzVirtualNetworkSubnetConfig @subnet3
    
    #associate subnet to vnet
    $virtualNetwork | Set-AzVirtualNetwork

    #create subnet 4
    Write-Host "Creating subnet 4: " $subnet4_name
    $subnet4 = @{
        Name = $subnet4_name
        VirtualNetwork = $virtualNetwork
        AddressPrefix = $subnet4_addressprefix 
    }
    $subnetConfig4 = Add-AzVirtualNetworkSubnetConfig @subnet4

    #associate subnet to vnet
    $virtualNetwork | Set-AzVirtualNetwork

    #create bastion
    Write-Host "Creating bastion : " $bastion_name
    $vm1 = @{
        ResourceGroupName = $rsg_name
        Location = $rsg_location
        Name = $bastion_name
        VirtualNetworkName = $vnet_name
        SubnetName = $subnet1_name
    }
    New-AzVM @vm1 -AsJob
    

    #Create database
    # Create a server with a system wide unique server name
    #$server = New-AzSqlServer -ResourceGroupName $rsg_name `
    #-ServerName $db_name `
    #-Location $rsg_location `
    #-SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $db_user, $(ConvertTo-SecureString -String $db_pass -AsPlainText -Force))

    # Create a server firewall rule that allows access from the specified IP range
    #$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $rsg_name `
    #-ServerName $db_name `
    #-FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp

    # Create a blank database with an S0 performance level
    #$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
    #-ServerName $db_name `
    #-DatabaseName $db_object_name `
    #-RequestedServiceObjectiveName "S0" `
    #-SampleName "AdventureWorksLT"