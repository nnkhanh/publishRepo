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