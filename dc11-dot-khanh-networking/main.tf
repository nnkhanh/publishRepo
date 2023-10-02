terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  backend "azurerm" {
        resource_group_name  = "DevOpsTraining"
        storage_account_name = "tfstate96"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
        #access_key = ""        
    }
}

kk

provider "azurerm" {
  features {}

  #subscription_id   = "9b4c827b-f9d9-4824-9cab-79c59cc8a808"
  #tenant_id         = "00361803-b14b-4604-8809-69c97fa1d059"
  #client_id         = "361f772c-d4ae-43fc-8e46-9d9ab5a2db26"
  #client_secret     = ""
}

# generate a random string
resource "random_string" "azustring" {
  length  = 10
  special = false
  upper   = false
  numeric  = false
}

locals {
  config_file_name      = "${terraform.workspace}.tfvars"
  full_config_file_path = "tfvars/${local.config_file_name}"
  vars                  = yamldecode(file(local.full_config_file_path))
}

resource "azurerm_resource_group" "main" {
  name     = "RG-${random_string.azustring.result}"
  location = local.vars.location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${random_string.azustring.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "subnet-fe-${random_string.azustring.result}"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "subnet-be-${random_string.azustring.result}"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "database" {
  name                 = "subnet-db-${random_string.azustring.result}"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

