terraform {
  required_version = ">= 1.0"
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

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.environment}-${var.project_name}-rg-${random_string.suffix.result}"
  location = var.location

  tags = var.tags
}

# Networking module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  vnet_address_space  = var.vnet_address_space
  subnet_config       = var.subnet_config
  tags                = var.tags
}

# Storage module
module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  subnet_id           = module.networking.storage_subnet_id
  private_dns_zone_id = module.networking.blob_private_dns_zone_id
  tags                = var.tags
}

# Database module
module "database" {
  source = "./modules/database"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment
  project_name        = var.project_name
  subnet_id           = module.networking.database_subnet_id
  private_dns_zone_id = module.networking.sql_private_dns_zone_id
  database_config     = var.database_config
  tags                = var.tags
}

# Compute module
module "compute" {
  source = "./modules/compute"

  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  environment           = var.environment
  project_name          = var.project_name
  frontend_subnet_id    = module.networking.frontend_subnet_id
  backend_subnet_id     = module.networking.backend_subnet_id
  app_service_config    = var.app_service_config
  sql_connection_string = module.database.connection_string
  storage_account_name  = module.storage.storage_account_name
  storage_account_key   = module.storage.storage_account_primary_key
  tags                  = var.tags

  depends_on = [
    module.networking,
    module.database,
    module.storage
  ]
}
