# Vm linux
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "vm-${random_string.azustring.result}"
  resource_group_name             = azurerm_resource_group.azurg.name
  location                        = azurerm_resource_group.azurg.location
  size                            = var.vm_size
  admin_username                  = var.vm_username
  network_interface_ids = [
    azurerm_network_interface.azuwebnic.id,
  ]

  admin_ssh_key {
    username = var.vm_username
    public_key = file("${var.vm_public_key}")
  }

  source_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}