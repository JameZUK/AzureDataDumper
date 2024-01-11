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
                $VNETLocation = $VNET.Location
                ForEach ($Subnet in $VNET.Subnets) {
                    $SubnetData = New-Object -Type PSObject
                    $SubnetData | Add-Member -Name 'VNETName' -Type NoteProperty -Value $VNETName
                    $SubnetData | Add-Member -Name 'VNETRG' -Type NoteProperty -Value $VNETRG
                    $SubnetData | Add-Member -Name 'VNETSub' -Type NoteProperty -Value $VNETSub
		            $SubnetData | Add-Member -Name 'SubnetName' -Type NoteProperty -Value $Subnet.Name
                    $SubnetData | Add-Member -Name 'SubnetAddressPrefix' -Type NoteProperty -Value "$($Subnet.AddressPrefix)"
                    $SubnetData | Add-Member -Name 'DNSServers' -Type NoteProperty -Value "$DNSServers"
                    $SubnetData | Add-Member -Name 'Location' -Type NoteProperty -Value "$VNETLocation"
                    $OutputList += $SubnetData
                }
		}

	}
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$OutputList | Export-Csv -Path VNETandSubnets.csv -NoTypeInformation
$OutputList | ogv