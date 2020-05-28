

try {
    Get-AzResourceGroup -Name "tx-static-rg" -Location "South Central US"
} catch {
    if ($_.ToString().Contains("exist")) {
        New-AzResourceGroup -Name "tx-static-rg" -Location "South Central US" 
    } else {
        throw $_
    }
}
Write-Host "Getting KeyVault"
try {
    Get-AzKeyVault -VaultName "bargerwebsecrets" -ResourceGroupName "tx-static-rg"
} catch {
    Write-Host $_.ToString()
}