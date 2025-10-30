terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Generate random password for SQL admin
resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
}

# Azure SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${var.environment}-${var.project_name}-sql-server"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sql_admin_password.result

  # Disable public network access - only private endpoints
  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name           = "${var.environment}-${var.project_name}-db"
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = var.database_config.sku_name
  zone_redundant = false

  # Serverless configuration
  auto_pause_delay_in_minutes = var.database_config.auto_pause_delay_in_minutes
  min_capacity               = var.database_config.min_capacity
  max_size_gb               = var.database_config.max_size_gb

  tags = var.tags
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql" {
  name                = "${var.environment}-${var.project_name}-sql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.environment}-${var.project_name}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

# Store SQL admin password in Key Vault (optional - for production use)
# Uncomment if you have a Key Vault module
# resource "azurerm_key_vault_secret" "sql_admin_password" {
#   name         = "sql-admin-password"
#   value        = random_password.sql_admin_password.result
#   key_vault_id = var.key_vault_id
# }
