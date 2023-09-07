# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.71"
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

provider "azurerm" {
  features {}

  #subscription_id   = "9b4c827b-f9d9-4824-9cab-79c59cc8a808"
  #tenant_id         = "00361803-b14b-4604-8809-69c97fa1d059"
  #client_id         = "361f772c-d4ae-43fc-8e46-9d9ab5a2db26"
  #client_secret     = ""
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "database" {
  name                 = "database"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = ["10.0.3.0/24"]
}