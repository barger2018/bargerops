
data "azurerm_key_vault" "keyvault" {
  name                = "bargerwebvault"
  resource_group_name = "tx-static-rg"
}

data "azurerm_key_vault_secret" "sql-username" {
  name         = "SQL-Admin-Username"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

data "azurerm_key_vault_secret" "sql-password" {
  name         = "SQL-Admin-Password"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

resource "azurerm_resource_group" "sql-rg" {
    name     = "${var.stateless-prefix}-sql-rg"
    location = "${var.location}"
}

resource "azurerm_storage_account" "sql-storage" {
  name                     = "bargerwebsqlstorage"
  resource_group_name      = "${azurerm_resource_group.sql-rg.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "sql-server" {
  name                         = "bargerwebsql"
  resource_group_name          = "${azurerm_resource_group.sql-rg.name}"
  location                     = "${var.location}"
  version                      = "12.0"
  administrator_login          = "${data.azurerm_key_vault_secret.sql-username.value}"
  administrator_login_password = "${data.azurerm_key_vault_secret.sql-password.value}"

  extended_auditing_policy {
    storage_endpoint                        = "${azurerm_storage_account.sql-storage.primary_blob_endpoint}"
    storage_account_access_key              = "${azurerm_storage_account.sql-storage.primary_access_key}"
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

}

resource "azurerm_sql_database" "db" {
  name                = "bargerwebdb"
  resource_group_name = "${azurerm_resource_group.sql-rg.name}"
  location            = "${var.location}"
  server_name         = "${azurerm_sql_server.sql-server.name}"

  extended_auditing_policy {
    storage_endpoint                        = "${azurerm_storage_account.sql-storage.primary_blob_endpoint}"
    storage_account_access_key              = "${azurerm_storage_account.sql-storage.primary_access_key}"
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }
}