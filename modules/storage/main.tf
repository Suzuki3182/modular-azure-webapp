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

# Generate random suffix for storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${var.environment}${var.project_name}st${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  account_kind             = "StorageV2"

  # Security settings
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"

  # Enable blob versioning and soft delete for production
  blob_properties {
    versioning_enabled  = var.environment == "prod"
    change_feed_enabled = var.environment == "prod"
    
    delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }

    container_delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.tags
}

# Storage Container for static assets
resource "azurerm_storage_container" "assets" {
  name                  = "assets"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Container for application data
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Private Endpoint for Blob Storage
resource "azurerm_private_endpoint" "blob" {
  name                = "${var.environment}-${var.project_name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.environment}-${var.project_name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blob-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

# Storage Account role assignments will be handled by the compute module
# based on the managed identities of the App Services
