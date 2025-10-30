output "server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.main.id
}

output "database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.main.name
}

output "connection_string" {
  description = "Connection string for the SQL Database"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${azurerm_mssql_server.main.administrator_login};Password=${random_password.sql_admin_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

output "admin_login" {
  description = "Administrator login for the SQL Server"
  value       = azurerm_mssql_server.main.administrator_login
  sensitive   = true
}

output "admin_password" {
  description = "Administrator password for the SQL Server"
  value       = random_password.sql_admin_password.result
  sensitive   = true
}
