
data "azurerm_virtual_network" "vnet" {
    name                = "${var.stateful-prefix}-vnet"
    resource_group_name = "${var.stateful-prefix}-rg"
}

data "azurerm_subnet" "backend" {
    name                 = "Backend"
    virtual_network_name = "${var.stateful-prefix}-vnet"
    resource_group_name  = "${var.stateful-prefix}-rg"
}

data "azurerm_key_vault" "keyvault" {
  name                = "bargerwebvault"
  resource_group_name = "tx-static-rg"
}

data "azurerm_key_vault_secret" "iis-username" {
  name         = "IIS-Vm-Username"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

data "azurerm_key_vault_secret" "iis-password" {
  name         = "IIS-Vm-Password"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

resource "azurerm_resource_group" "iis-rg" {
    name     = "${var.stateless-prefix}-iis-rg"
    location = "${var.location}"
}

resource "azurerm_network_interface" "iis-nic" {
  name                = "${var.stateless-prefix}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.iis-rg.name}"

  ip_configuration {
    name                          = "${var.stateless-prefix}-pvt-ip"
    subnet_id                     = "${data.azurerm_subnet.backend.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "iis-vm" {
  name                  = "${var.stateless-prefix}-vm"
  location              = "${var.location}"
  resource_group_name   = "${var.stateless-prefix}-iis-rg"
  network_interface_ids = ["${azurerm_network_interface.iis-nic.id}"]
  vm_size               = "Standard_D4a_v4"

   delete_os_disk_on_termination = true
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.stateless-prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_windows_config {
      enable_automatic_upgrades = "true"
      provision_vm_agent = "true"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "${data.azurerm_key_vault_secret.iis-username.value}"
    admin_password = "${data.azurerm_key_vault_secret.iis-password.value}"
  }

}

# resource "azurerm_virtual_machine_extension" "iis-ext" {
#   name                 = "${var.stateless-prefix}-extension"
#   virtual_machine_id   = "${azurerm_virtual_machine.iis-vm.id}"
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.9"

#   settings = <<SETTINGS
#     {
#       "fileUris": [
#         "https://dev.azure.com/bargerweb/_git/BargerOps?path=%2FPowerShell%2FCustomScripts%2FHello.ps1"
#       ],
#       "commandToExecute": "[parameters('extensions_CustomScriptExtension_commandToExecute')]"
#     }
# SETTINGS

# }