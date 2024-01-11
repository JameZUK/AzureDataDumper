$Subs = Get-AzSubscription

$OutputList = @()
try {
	Foreach ($Sub in $Subs) {
		Set-AzContext -Subscription $Sub.id *>$null
		$RGs =  Get-AzResourceGroup
		foreach ($RG in $RGs) {
                $RGName = $RG.ResourceGroupName
                $RGLocation = $RG.Location
                $RGSub = $Sub.Name
                $RGData = New-Object -Type PSObject
                $RGData | Add-Member -Name 'RGSub' -Type NoteProperty -Value $RGSub
                $RGData | Add-Member -Name 'RGName' -Type NoteProperty -Value $RGName
                $RGData | Add-Member -Name 'RGLocation' -Type NoteProperty -Value $RGLocation
                $OutputList += $RGData
		}
	}
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$OutputList | Export-Csv -Path RGs.csv -NoTypeInformation
$OutputList | ogv