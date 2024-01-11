$Subs = Get-AzSubscription

$OutputList = @()
try {
	Foreach ($Sub in $Subs) {
		Set-AzContext -Subscription $Sub.id *>$null
		$Routes =  Get-AzRouteTable
		foreach ($Route in $Routes) {
                $RouteName = $Route.Name
                #$RouteRG = $Route.ResourceGroupName
                $RouteSub = $Sub.Name
                $RouteAddrPrefix = ($Route.RoutesText | ConvertFrom-Json).AddressPrefix -Join ", "
                $RouteNextHopType = ($Route.RoutesText | ConvertFrom-Json).NextHopType -Join ","
                $RouteNextHopIpAddress = ($Route.RoutesText | ConvertFrom-Json).NextHopIpAddress -Join ","

                $SubnetName = ""
                $RouteSubnets = ($Route.SubnetsText | ConvertFrom-Json)
                ForEach ($subnet in $RouteSubnets.Id) {
            	    $SubnetName += ($subnet -split("/"))[-1] + ", "
                }
                        $RouteData = New-Object -Type PSObject
                        $RouteData | Add-Member -Name 'RouteName' -Type NoteProperty -Value $RouteName
                        #$SubnetData | Add-Member -Name 'VNETRG' -Type NoteProperty -Value $VNETRG
                        $RouteData | Add-Member -Name 'RouteSubscription-' -Type NoteProperty -Value $RouteSub
                        #$SubnetData | Add-Member -Name 'VNETPrefix' -Type NoteProperty -Value $AddressSpaces
                        #$SubnetData | Add-Member -Name 'DNSServers' -Type NoteProperty -Value "$DNSServers"
                        $RouteData | Add-Member -Name 'RouteAddressPrefix' -Type NoteProperty -Value $RouteAddrPrefix
                        $RouteData | Add-Member -Name 'RouteNextHopType' -Type NoteProperty -Value $RouteNextHopType
                        $RouteData | Add-Member -Name 'RouteNextHopIpAddress' -Type NoteProperty -Value $RouteNextHopIpAddress
                        $RouteData | Add-Member -Name 'RouteSubnets' -Type NoteProperty -Value $SubnetName
                        $OutputList += $RouteData
		}

	}
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$OutputList | Export-Csv -Path UDRRoutes.csv -NoTypeInformation
$OutputList | ogv