terraform {
    backend "azurerm" {
      storage_account_name = "may27storage"
      container_name       = "tfstate"
      
   }
 }

 provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.4.0"

  subscription_id = "${var.subscription-id}"
  client_id       = "${var.client-id}"
  client_secret   = "${var.client-secret}"
  tenant_id       = "${var.tennant-id}"
  
  features {}
 }

module serverless {
  source = "./mod-serverless"

  stateless-prefix = "${var.stateless-prefix}"
     stateful-prefix = "${var.stateful-prefix}"
     location = "${var.location}"
}

module sql {
  source = "./mod-sql"

  stateless-prefix = "${var.stateless-prefix}"
     stateful-prefix = "${var.stateful-prefix}"
     location = "${var.location}"
}
 module vm {
     source = "./mod-vm"

     stateless-prefix = "${var.stateless-prefix}"
     stateful-prefix = "${var.stateful-prefix}"
     location = "${var.location}"

 }