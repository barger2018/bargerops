resource "azurerm_resource_group" "func-rg" {
    name     = "${var.stateless-prefix}-func-rg"
    location = "${var.location}"
}

resource "azurerm_storage_account" "func-storage" {
  name                     = "bargerwebfuncstorage"
  resource_group_name      = "${var.stateless-prefix}-func-rg"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "func-plan" {
  name                = "${var.stateless-prefix}-func-plan"
  location            = "${var.location}"
  resource_group_name = "${var.stateless-prefix}-func-rg"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "func" {
  name                      = "${var.stateless-prefix}-func"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.func-rg.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.func-plan.id}"
  storage_connection_string = "${azurerm_storage_account.func-storage.primary_connection_string}"
}