

$storageAccount

try {
    Get-AzResourceGroup -Name "tx-static-rg" -Location "South Central US"
} catch {
    if ($_.ToString().Contains("exist")) {
        New-AzResourceGroup -Name "tx-static-rg" -Location "South Central US" 
    } else {
        throw $_
    }
}

try {
    $storageAccount = Get-AzStorageAccount -ResourceGroupName "tx-static-rg" -Name "may27storage"
} catch {
    if ($_.ToString().Contains("not found")) {
        $storageAccount = New-AzStorageAccount -ResourceGroupName "tx-static-rg" `
            -Location "South Central US" `
            -SkuName "Standard_RAGRS" `
            -Kind "StorageV2" `
            -AccessTier "Hot" `
            -Name "may27storage"
    } else {
        throw $_
    }
}

try {
    Get-AzStorageContainer -Name "tfstate" -Context $storageAccount.Context
} catch {
    if ($_.ToString().Contains("not find")) {
        New-AzStorageContainer -Name "tfstate" -Context $storageAccount.Context -Permission "Blob"
    } else {
        throw $_
    }
}