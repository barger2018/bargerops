
$clientId = $env:CLIENT_ID
$secretId = $env:CLIENT_SECRET
$tennantId = $env:TENNANT_ID

$password = ConvertTo-SecureString $secretId -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($clientId, $password)

Install-Module -Name Az -AllowClobber -Confirm:$False -Force
Connect-AzAccount -Credential $credential -Tenant $tennantId -ServicePrincipal
Get-AzSubscription

$keys = Get-AzStorageAccountKey -ResourceGroupName "tx-static-rg" -Name "may27storage"
$key = $keys.Value[0]

Set-Location "$env:AGENT_RELEASEDIRECTORY\_BargerOps-CI\Job1\s\Terraform"

terraform init `
    -backend-config="key=$env:STATELESS_PREFIX.terraform.tfstate" `
    -backend-config="access_key=$key"

terraform workspace new $env:STATELESS_PREFIX
terraform workspace select $env:STATELESS_PREFIX

terraform init `
    -backend-config="key=$env:STATELESS_PREFIX.terraform.tfstate" `
    -backend-config="access_key=$key"

terraform apply -auto-approve `
    -var="location=$env:LOCATION" `
    -var="stateful-prefix=$env:STATEFUL_PREFIX" `
    -var="stateless-prefix=$env:STATELESS_PREFIX" `
    -var="subscription-id=$env:SUBSCRIPTION_ID" `
    -var="tennant-id=$env:TENNANT_ID" `
    -var="client-id=$env:CLIENT_ID" `
    -var="client-secret=$env:CLIENT_SECRET" 