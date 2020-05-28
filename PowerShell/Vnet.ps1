param ($statefulPrefix, $location)

$vnet
$ipconf
$pip
$gwsub
$gw
$FESubName = "FrontEnd"
$BESubName = "Backend"
$GWSubName = "GatewaySubnet"
$VNetPrefix1 = "192.168.0.0/16"
$FESubPrefix = "192.168.1.0/24"
$BESubPrefix = "192.168.2.0/24"
$GWSubPrefix = "192.168.200.0/26"
$VPNClientAddressPool = "172.16.201.0/24"

try {
    Get-AzResourceGroup -Name "$statefulPrefix-rg" -Location $location
} catch {
    if ($_.ToString().Contains("exist")) {
        New-AzResourceGroup -Name "$statefulPrefix-rg" -Location $location
    } else {
        throw $_
    }
}

try {
    $vnet = Get-AzVirtualNetwork -Name "$statefulPrefix-vnet" -ResourceGroupName "$statefulPrefix-rg"
} catch {
    if ($_.ToString().Contains("not found")) {

        $fesub = New-AzVirtualNetworkSubnetConfig -Name $FESubName -AddressPrefix $FESubPrefix
        $besub = New-AzVirtualNetworkSubnetConfig -Name $BESubName -AddressPrefix $BESubPrefix
        $gwsub = New-AzVirtualNetworkSubnetConfig -Name $GWSubName -AddressPrefix $GWSubPrefix

        $vnet = New-AzVirtualNetwork -Name "$statefulPrefix-vnet" -Location $location `
            -ResourceGroupName "$statefulPrefix-rg" `
            -AddressPrefix $VNetPrefix1 `
            -Subnet $fesub, $besub, $gwsub 
    } else {
        throw $_
    }
}

try {
    $pip = Get-AzPublicIpAddress -Name "$statefulPrefix-gw-ip" -ResourceGroupName "$statefulPrefix-rg"
} catch {
    if ($_.ToString().Contains("not found")) {
        $pip = New-AzPublicIpAddress -Name "$statefulPrefix-gw-ip" -ResourceGroupName "$statefulPrefix-rg" -Location $location -AllocationMethod Dynamic
    } else {
        throw $_
    }
}

$gwsub = Get-AzVirtualNetworkSubnetConfig -Name $GWSubName -VirtualNetwork $vnet
$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name "$statefulPrefix-gw-ip-conf" -Subnet $gwsub -PublicIpAddress $pip
try {
    $gw = Get-AzVirtualNetworkGateway -Name "$statefulPrefix-gw" -ResourceGroupName "$statefulPrefix-rg"
} catch {
    if ($_.ToString().Contains("not found")) {
        Write-Host "Creating Gateway..."
        $gw = New-AzVirtualNetworkGateway -Name "$statefulPrefix-gw" -ResourceGroupName "$statefulPrefix-rg" `
            -Location $location -IpConfigurations $ipconf -GatewayType Vpn `
            -VpnType RouteBased -EnableBgp $false -GatewaySku VpnGw1 -VpnClientProtocol "IKEv2"
    }
}

Set-AzVirtualNetworkGateway -VirtualNetworkGateway $gw -VpnClientAddressPool $VPNClientAddressPool

$filePathForCert = "$env:AGENT_RELEASEDIRECTORY\_BargerOps-CI\Job1\s\Powershell\rootcert.cer"
$cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)
$CertBase64 = [system.convert]::ToBase64String($cert.RawData)
New-AzVpnClientRootCertificate -Name "$statefulPrefix-root-cert" -PublicCertData $CertBase64

try {
Add-AzVpnClientRootCertificate -VpnClientRootCertificateName "$statefulPrefix-root-cert" `
    -VirtualNetworkGatewayname "$statefulPrefix-gw" `
    -ResourceGroupName "$statefulPrefix-rg" `
    -PublicCertData $CertBase64 
} catch {
    #Empty catch block on purpose!
}