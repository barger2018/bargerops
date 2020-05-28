
Get-AzSubscription
Get-AzContext

& "$env:AGENT_RELEASEDIRECTORY\_BargerOps-CI\Job1\s\Powershell\StateStorage.ps1"
& "$env:AGENT_RELEASEDIRECTORY\_BargerOps-CI\Job1\s\Powershell\KeyVault.ps1"
& "$env:AGENT_RELEASEDIRECTORY\_BargerOps-CI\Job1\s\Powershell\Vnet.ps1" -statefulPrefix $env:STATEFUL_PREFIX -location $env:LOCATION

    
        # $keys = Get-AzStorageAccountKey -ResourceGroupName "tx-static" -Name "may27storage"
        # $key = $keys.Value[0]

        # Set-Location -Path "$env:AGENT_RELEASEDIRECTORY\_BargerOps-CI\Job1\s\Terraform"
        # Get-Location
        # terraform init `
        #   -backend-config="key=$env:STATELESS_PREFIX.terraform.tfstate" `
        #   -backend-config="access_key=$key"

        # terraform workspace new $env:STATELESS_PREFIX
        # terraform workspace select $env:STATELESS_PREFIX

        # terraform init `
        #   -backend-config="key=$env:STATELESS_PREFIX.terraform.tfstate" `
        #   -backend-config="access_key=$key"
          
        # terraform apply -auto-approve `
        #  -var="stateless-prefix=$env:STATELESS_PREFIX" `
        #  -var="location=$env:LOCATION" `
        #  -var="client-id=$env:CLIENT_ID" `
        #  -var="client-secret=$env:CLIENT_SECRET" `
        #  -var="subscription-id=$env:SUBSCRIPTION_ID" `
        #  -var="tennant-id=$env:TENNANT_ID" 
#     }

#     "destroy" {
#       terraform destroy -auto-approve `
#          -var="stateless-prefix=$env:STATELESS_PREFIX" `
#          -var="location=$env:LOCATION" `
#          -var="client-id=$env:CLIENT_ID" `
#          -var="client-secret=$env:CLIENT_SECRET" `
#          -var="subscription-id=$env:SUBSCRIPTION_ID" `
#          -var="tennant-id=$env:TENNANT_ID" 
#     }
# }


