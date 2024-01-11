$Subs = Get-AzSubscription

$OutputList = @()
try {
	Foreach ($Sub in $Subs) {
		Set-AzContext -Subscription $Sub.id *>$null
		$VNETs =  Get-AzVirtualNetwork
		foreach ($VNET in $VNETs) {
                $VNETName = $VNET.Name
                $VNETRG = $VNET.ResourceGroupName
                $VNETSub = $Sub.Name
                $DNSServers = ($VNET.DhcpOptionsText | ConvertFrom-Json).DnsServers -Join ", "
                $AddressSpaces = ($VNET.AddressSpaceText | ConvertFrom-Json).AddressPrefixes -Join ","
                $VNETLocation = $VNET.Location

                $Peers = ($VNET.VirtualNetworkPeeringsText | ConvertFrom-Json)
                ForEach ($Peer in $Peers) {
                    $PeeringName = $Peer.Name
                    $PeeringRemote = $Peer.RemoteVirtualNetwork

                    ForEach ($PeeRemote in $PeeringRemote) {
                        $Peee = ($PeeRemote -split("/"))[-1] -replace("}","")
                        $SubnetData = New-Object -Type PSObject
                        $SubnetData | Add-Member -Name 'VNETName' -Type NoteProperty -Value $VNETName
                        #$SubnetData | Add-Member -Name 'VNETRG' -Type NoteProperty -Value $VNETRG
                        #$SubnetData | Add-Member -Name 'VNETSub' -Type NoteProperty -Value $VNETSub
                        #$SubnetData | Add-Member -Name 'VNETPrefix' -Type NoteProperty -Value $AddressSpaces
                        #$SubnetData | Add-Member -Name 'DNSServers' -Type NoteProperty -Value "$DNSServers"
                        $SubnetData | Add-Member -Name 'Location' -Type NoteProperty -Value "$VNETLocation"
                        $SubnetData | Add-Member -Name 'PeeringName' -Type NoteProperty -Value $PeeringName
                        $SubnetData | Add-Member -Name 'PeeringRemote' -Type NoteProperty -Value $Peee
                        $OutputList += $SubnetData
                    }
                 }
		}

	}
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$OutputList | Export-Csv -Path VNETPeers.csv -NoTypeInformation
$OutputList | ogv