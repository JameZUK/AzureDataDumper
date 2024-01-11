$Subs = Get-AzSubscription

$OutputList = @()
try {
	Foreach ($Sub in $Subs) {
		Set-AzContext -Subscription $Sub.id *>$null
		$RSV = Get-AzRecoveryServicesVault
		foreach ($Vault in $RSV) {
            $Containers = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vault.ID
            ForEach ($Container in $Containers) {
                $BackupItem = Get-AzRecoveryServicesBackupItem -Container $Container -WorkloadType AzureVM -VaultId $vault.ID
                $VMName = $Container.FriendlyName
                $VMBackupPolicy = $BackupItem.ProtectionPolicyName
                $AzRecoveryServicesBackupProperty = Get-AzRecoveryServicesBackupProperty -Vault $Vault
                $BackupStorageRedundancy = $AzRecoveryServicesBackupProperty.BackupStorageRedundancy
                $CrossRegionRestore = $AzRecoveryServicesBackupProperty.CrossRegionRestore

                $Bkp = New-Object -Type PSObject
                $Bkp | Add-Member -Name 'VMName' -Type NoteProperty -Value $VMName
                $Bkp | Add-Member -Name 'VMBackupPolicy' -Type NoteProperty -Value $VMBackupPolicy
                $Bkp | Add-Member -Name 'BackupStorageRedundancy' -Type NoteProperty -Value $BackupStorageRedundancy
                $Bkp | Add-Member -Name 'CrossRegionRestore' -Type NoteProperty -Value $CrossRegionRestore
                $OutputList += $Bkp
            }
        }
	}
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$OutputList | Export-Csv -Path VMBackupDetails.csv -NoTypeInformation
$OutputList | ogv