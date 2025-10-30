output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "app_service_urls" {
  description = "URLs of the App Services"
  value = {
    frontend = module.compute.frontend_app_service_url
    backend  = module.compute.backend_app_service_url
  }
  sensitive = false
}

output "database_connection_info" {
  description = "Database connection information"
  value = {
    server_name   = module.database.server_name
    database_name = module.database.database_name
    server_fqdn   = module.database.server_fqdn
  }
  sensitive = false
}

output "storage_account_info" {
  description = "Storage account information"
  value = {
    name                  = module.storage.storage_account_name
    primary_blob_endpoint = module.storage.primary_blob_endpoint
  }
  sensitive = false
}

output "networking_info" {
  description = "Networking information"
  value = {
    vnet_name = module.networking.vnet_name
    vnet_id   = module.networking.vnet_id
    subnet_ids = {
      frontend = module.networking.frontend_subnet_id
      backend  = module.networking.backend_subnet_id
      database = module.networking.database_subnet_id
      storage  = module.networking.storage_subnet_id
    }
  }
  sensitive = false
}

# Sensitive outputs for application configuration
output "database_connection_string" {
  description = "Complete database connection string"
  value       = module.database.connection_string
  sensitive   = true
}

output "storage_account_key" {
  description = "Primary access key for storage account"
  value       = module.storage.storage_account_primary_key
  sensitive   = true
}
