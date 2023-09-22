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

provider "azurerm" {
  features {}

  #subscription_id   = "9b4c827b-f9d9-4824-9cab-79c59cc8a808"
  #tenant_id         = "00361803-b14b-4604-8809-69c97fa1d059"
  #client_id         = "361f772c-d4ae-43fc-8e46-9d9ab5a2db26"
  #client_secret     = ""
}

resource "azurerm_resource_group" "azurg" {
  name     = "RG-${terraform.workspace}-${random_string.azustring.result}"
  location = var.location

  tags = {
    environment = "${terraform.workspace}"   
  }
}