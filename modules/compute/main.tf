terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# App Service Plan for Frontend
resource "azurerm_service_plan" "frontend" {
  name                = "${var.environment}-${var.project_name}-frontend-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.app_service_config.frontend_os_type
  sku_name            = var.app_service_config.frontend_sku_name

  tags = var.tags
}

# App Service Plan for Backend
resource "azurerm_service_plan" "backend" {
  name                = "${var.environment}-${var.project_name}-backend-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.app_service_config.backend_os_type
  sku_name            = var.app_service_config.backend_sku_name

  tags = var.tags
}

# Frontend App Service
resource "azurerm_linux_web_app" "frontend" {
  name                = "${var.environment}-${var.project_name}-frontend-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.frontend.id

  site_config {
    always_on = var.app_service_config.frontend_sku_name != "F1" && var.app_service_config.frontend_sku_name != "D1"
    
    application_stack {
      node_version = "18-lts"
    }

    # Security headers
    http2_enabled = true
    ftps_state    = "Disabled"
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18.17.0"
    "BACKEND_API_URL"             = "https://${azurerm_linux_web_app.backend.default_hostname}"
    "ENVIRONMENT"                 = var.environment
  }

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  tags = var.tags
}

# Backend App Service
resource "azurerm_linux_web_app" "backend" {
  name                = "${var.environment}-${var.project_name}-backend-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.backend.id

  site_config {
    always_on = var.app_service_config.backend_sku_name != "F1" && var.app_service_config.backend_sku_name != "D1"
    
    application_stack {
      node_version = "18-lts"
    }

    # Security headers
    http2_enabled = true
    ftps_state    = "Disabled"

    # IP restrictions - only allow frontend subnet
    ip_restriction {
      virtual_network_subnet_id = var.frontend_subnet_id
      priority                  = 100
      action                    = "Allow"
      name                      = "AllowFrontendSubnet"
    }
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18.17.0"
    "DATABASE_CONNECTION_STRING"   = var.sql_connection_string
    "STORAGE_ACCOUNT_NAME"         = var.storage_account_name
    "STORAGE_ACCOUNT_KEY"          = var.storage_account_key
    "ENVIRONMENT"                  = var.environment
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = var.sql_connection_string
  }

  identity {
    type = "SystemAssigned"
  }

  https_only = true

  tags = var.tags
}

# VNet Integration for Backend App Service
resource "azurerm_app_service_virtual_network_swift_connection" "backend" {
  app_service_id = azurerm_linux_web_app.backend.id
  subnet_id      = var.backend_subnet_id
}

# Custom domain and SSL certificate can be added here if needed
# resource "azurerm_app_service_custom_hostname_binding" "frontend" {
#   hostname            = "www.example.com"
#   app_service_name    = azurerm_linux_web_app.frontend.name
#   resource_group_name = var.resource_group_name
# }
