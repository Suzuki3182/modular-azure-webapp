output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "frontend_subnet_id" {
  description = "ID of the frontend subnet"
  value       = azurerm_subnet.frontend.id
}

output "backend_subnet_id" {
  description = "ID of the backend subnet"
  value       = azurerm_subnet.backend.id
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.database.id
}

output "storage_subnet_id" {
  description = "ID of the storage subnet"
  value       = azurerm_subnet.storage.id
}

output "sql_private_dns_zone_id" {
  description = "ID of the SQL private DNS zone"
  value       = azurerm_private_dns_zone.sql.id
}

output "blob_private_dns_zone_id" {
  description = "ID of the Blob private DNS zone"
  value       = azurerm_private_dns_zone.blob.id
}
