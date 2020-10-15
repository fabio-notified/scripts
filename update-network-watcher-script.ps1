#resource groups to look for vm:s
$resource_groups = @("Notified", "Notified-Test", "Notified-Staging", "Infrastructure")
$publisher = "Microsoft.Azure.NetworkWatcher"
$windows_agent = "NetworkWatcherAgentWindows"
$linux_agent = "NetworkWatcherAgentLinux"

# store the vm:s in an array
$virtual_machines = @()

$resource_groups | ForEach-Object -Process { 

    $resource_group_name = $_

    # Get virtual machines and create an custom object of desired properties
    $virtual_machine_items = az vm list -g $resource_group_name  --query "[].{ name:name, group:resourceGroup, machineType:storageProfile.osDisk.osType, location:location}" | ConvertFrom-Json 

    $virtual_machine_items | ForEach-Object {

        # Set agent type
        $agent = $_.machineType -eq "Windows" ? $windows_agent : $linux_agent

        # Check if the virtual machines has the extension already
        $has_extension = (az vm extension list --resource-group  $_.group --vm-name $_.name | ConvertFrom-Json  | Where-Object -Property name -Like "AzureNetworkWatcherExtension") -ne $null ? $true : $false
  
        $extension_command = "az vm extension set --resource-group $($_.group) --vm-name $($_.name) --name $agent --publisher $publisher"

        $command = $has_extension ?  $extension_command + " --force-update" : $extension_command

        # Add command as a custom property to the vm object 
        $_ | Add-Member -MemberType NoteProperty -Name command -Value $command

        $virtual_machines += $_
    }
}

$virtual_machines | ForEach-Object  -Parallel { Invoke-Expression -Command $_.command  } -ThrottleLimit 10
   
    


