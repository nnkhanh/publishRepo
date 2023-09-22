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