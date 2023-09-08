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


# generate a random prefix
resource "random_string" "azustring" {
  length  = 10
  special = false
  upper   = false
  numeric  = false
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
  name                = "virtualNetwork1"
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
  name                 = "publicsubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Subnet for dbs
resource "azurerm_subnet" "azuprivatesubnet" {
  name                 = "privatesubnet"
  resource_group_name  = azurerm_resource_group.azurg.name
  virtual_network_name = azurerm_virtual_network.azuvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP for web server
resource "azurerm_public_ip" "azuvmpip" {
  name                = "vm-pip"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "${terraform.workspace}"
  }
}

// NIC
resource "azurerm_network_interface" "azuwebnic" {
  name                = "web-nic"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.azupublicsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azuvmpip.id
  }
}


# NSG for pubsubnet
resource "azurerm_network_security_group" "azunsgpubsubnet" {
  name                = "webnsg"
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

# NSG for privatesubnet
resource "azurerm_network_security_group" "azunsgprivatesubnet" {
  name                = "dbnsg"
  resource_group_name = azurerm_resource_group.azurg.name
  location            = azurerm_resource_group.azurg.location

  security_rule {
    name                       = "sqlrule"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.0.0/24"
    destination_address_prefix = "*"
  }
}


resource "azurerm_subnet_network_security_group_association" "webfe-nsgass-01" {
  subnet_id                 = azurerm_subnet.azupublicsubnet.id
  network_security_group_id = azurerm_network_security_group.azunsgpubsubnet.id
}

resource "azurerm_subnet_network_security_group_association" "db-nsgass-01" {
  subnet_id                 = azurerm_subnet.azuprivatesubnet.id
  network_security_group_id = azurerm_network_security_group.azunsgprivatesubnet.id
}

# Vm linx
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "vm-${random_string.azustring.result}"
  resource_group_name             = azurerm_resource_group.azurg.name
  location                        = azurerm_resource_group.azurg.location
  size                            = "Standard_D1_v2"
  admin_username                  = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.azuwebnic.id,
  ]

  admin_ssh_key {
    username = "azureuser"
    public_key = file("~/.ssh/nnkhanh-GitHub.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

# Create managed instance
resource "azurerm_mssql_managed_instance" "main" {
  name                         = "mssql1"
  resource_group_name          = azurerm_resource_group.azurg.name
  location                     = azurerm_resource_group.azurg.location
  subnet_id                    = azurerm_subnet.azuprivatesubnet.id
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"
  license_type                 = "BasePrice"
  sku_name                     = "GP_Gen5"
  vcores                       = "4"
  storage_size_in_gb           = "32"
}
