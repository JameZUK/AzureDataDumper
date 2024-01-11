$Subs = Get-AzSubscription

$OutputList = @()
try {
	Foreach ($Sub in $Subs) {
		Set-AzContext -Subscription $Sub.id *>$null
		$PrivateEndpoints =  Get-AzPrivateEndpoint
		foreach ($PrivateEndpoint in $PrivateEndpoints) {
            $PrivateEndpointName = $PrivateEndpoint.Name
            $PrivateEndpointRG = $PrivateEndpoint.ResourceGroupName              
            $PrivateEndpointSubResource = ($PrivateEndpoint.PrivateLinkServiceConnectionsText | ConvertFrom-Json).GroupIDs -Join ", "
            $PrivateEndpointIPs = $PrivateEndpoint.CustomDnsConfigs.IpAddresses -Join ", "
            $PrivateEndpointResource = ($PrivateEndpoint.Id -split("/"))[-1]
            $PrivateEndpointVNET = ((($PrivateEndpoint.SubnetText | ConvertFrom-Json).Id) -split("/"))[8] + "/" + ((($PrivateEndpoint.SubnetText | ConvertFrom-Json).Id) -split("/"))[10]
            #$PrivateEndpointVNET
            #($PrivateEndpoint.SubnetText | ConvertFrom-Json).Id

            $PED = New-Object -Type PSObject
            $PED | Add-Member -Name 'PrivateEndpointName' -Type NoteProperty -Value $PrivateEndpointName
            $PED | Add-Member -Name 'PrivateEndpointRG-' -Type NoteProperty -Value $PrivateEndpointRG
            $PED | Add-Member -Name 'PrivateEndpointSubResource' -Type NoteProperty -Value $PrivateEndpointSubResource
            $PED | Add-Member -Name 'PrivateEndpointIPs' -Type NoteProperty -Value $PrivateEndpointIPs
            $PED | Add-Member -Name 'PrivateEndpointResource' -Type NoteProperty -Value $PrivateEndpointResource
            $PED | Add-Member -Name 'PrivateEndpointVNET' -Type NoteProperty -Value $PrivateEndpointVNET
            $OutputList += $PED
        }
	}
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$OutputList | Export-Csv -Path PrivateEndpoints.csv -NoTypeInformation
$OutputList | ogv