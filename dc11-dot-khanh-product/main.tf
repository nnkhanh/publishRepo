terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71"
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


# generate a random string
resource "random_string" "azustring" {
  length  = 10
  special = false
  upper   = false
  numeric  = false
}

# generate a random pwd
resource "random_password" "password" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "azurerm_resource_group" "azurg" {
  name     = "RG-${terraform.workspace}-${random_string.azustring.result}"
  location = var.location

  tags = {
    environment = "${terraform.workspace}"   
  }
}

# Virtual network 
resource "azurerm_virtual_network" "azuvnet" {
  name                = "vnet-${terraform.workspace}-${random_string.azustring.result}"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  address_space       = ["10.0.0.0/16"]
  #dns_servers         = ["168.63.129.16", "8.8.8.8"]

  tags = {
    environment = "${terraform.workspace}"   
  }
}

# Subnet for web servers
resource "azurerm_subnet" "azupublicsubnet" {
  name                 = "pubsub-${terraform.workspace}-${random_string.azustring.result}"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet for dbs
resource "azurerm_subnet" "azuprivatesubnet" {
  name                 = "prisub-${terraform.workspace}-${random_string.azustring.result}"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# NSG for pubsubnet
resource "azurerm_network_security_group" "azunsgpubsubnet" {
  name                = "nsg-web-${terraform.workspace}-${random_string.azustring.result}"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  security_rule {
    name                       = "myssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate nsgs to subnets
resource "azurerm_subnet_network_security_group_association" "nsg_ass_pubsub" {
  subnet_id                 = azurerm_subnet.azupublicsubnet.id
  network_security_group_id = azurerm_network_security_group.azunsgpubsubnet.id
}

# Public IP for web server
resource "azurerm_public_ip" "azuvmpip" {
  name                = "pip-${terraform.workspace}-${random_string.azustring.result}"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "${terraform.workspace}"
  }
}

// NIC
resource "azurerm_network_interface" "azuwebnic" {
  name                = "nic-${terraform.workspace}-${random_string.azustring.result}"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.azupublicsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azuvmpip.id
  }
}

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

# Enables you to manage Private DNS zones within Azure DNS
resource "azurerm_private_dns_zone" "default" {
  name                        = "${random_string.azustring.result}.mysql.database.azure.com"
  resource_group_name         = azurerm_resource_group.azurg.name
}

# Enables you to manage Private DNS zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                        = "mysql_dns_vnet_link${random_string.azustring.result}.com"
  private_dns_zone_name       = azurerm_private_dns_zone.default.name
  resource_group_name         = azurerm_resource_group.azurg.name
  virtual_network_id          = azurerm_virtual_network.azuvnet.id
}

# Create myql
resource "azurerm_mysql_flexible_server" "my_sql" {
  name                         = "db-mysql-${random_string.azustring.result}"
  resource_group_name          = azurerm_resource_group.azurg.name
  location                     = azurerm_resource_group.azurg.location
  administrator_login          = random_string.azustring.result
  administrator_password       = random_password.password.result
  geo_redundant_backup_enabled = false
  backup_retention_days        = 7
  private_dns_zone_id          = azurerm_private_dns_zone.default.id
  delegated_subnet_id          = azurerm_subnet.azuprivatesubnet.id
  sku_name                     = "GP_Standard_D2ds_v4"
  version                      = "8.0.21"
  zone                         = "1"

  storage {
    iops    = 360
    size_gb = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}
