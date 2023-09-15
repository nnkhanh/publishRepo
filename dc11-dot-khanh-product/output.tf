output "azurerm_mysql_flexible_server" {
  value = azurerm_mysql_flexible_server.my_sql.name
}

output "admin_login" {
  value = azurerm_mysql_flexible_server.my_sql.administrator_login
}

output "admin_password" {
  sensitive = true
  value     = azurerm_mysql_flexible_server.my_sql.administrator_password
}