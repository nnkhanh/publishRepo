provider "azurerm" {
  features {}
}

data "azurerm_key_vault" "devopstraining" {
  name                = "devopstraining"
  resource_group_name = "DevOpsTraining"
}

data "azurerm_key_vault_secret" "terraform-backend-key" {
  name         = "terraform-backend-key"
  key_vault_id = data.azurerm_key_vault.devopstraining.id
}

output "secret_value" {
  value     = data.azurerm_key_vault_secret.terraform-backend-key.value
  sensitive = true
}