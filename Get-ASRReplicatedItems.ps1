# Get all Azure subscriptions
$subscriptions = Get-AzSubscription

# Create an array to store the results
$results = @()

# Loop through each subscription
foreach ($subscription in $subscriptions) {
    
    # Select the current subscription
    Set-AzContext -SubscriptionId $subscription.Id

# Get all vaults
$vaults = Get-AzRecoveryServicesVault

# Loop through each vault
foreach ($vault in $vaults) {
    
    # Select the current vault
    Set-AzRecoveryServicesAsrVaultContext -Vault $vault

# Get all fabrics
$fabrics = Get-AzRecoveryServicesAsrFabric

# Loop through each fabric
foreach ($fabric in $fabrics) {
    
    # Get the asr container
    $container = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $fabric
    
    # Get protected Items
    $items= Get-AzRecoveryServicesAsrReplicationProtectedItem -ProtectionContainer $container

# Loop through each item
foreach ($item in $items) {

        # Check if replication is enabled for the virtual machine
        if ($item -ne $null) {
        
        # Get VM object to be able to populate with VM parameters
        $vm = get-azvm | Where-Object { $_.Name -match $item.FriendlyName}
        
            $result = [PSCustomObject]@{
                "Subscription" = $subscription.Name
                "RecoveryVault" = $vault.Name
                "Fabric" = $fabric.Name
                "VirtualMachineName" = $item.FriendlyName
                "AppName" = $vm.Tags.AppName
                "ActiveLocation" = $item.ActiveLocation
                "ProtectionState" = $item.ProtectionState
                "ReplicationHealth" = $item.ReplicationHealth

            } 
            $results += $result
            } #end if

} #end VM loop

} #end fabric loop

} #end vault loop

} #end sub loop

$results | ogv
$results | Export-Csv -Path "VirtualMachineReplicationStatus.csv" -NoTypeInformation
