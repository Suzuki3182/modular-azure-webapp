terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.environment}-${var.project_name}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Frontend Subnet (Public-facing App Service)
resource "azurerm_subnet" "frontend" {
  name                 = "${var.environment}-${var.project_name}-frontend-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_config.frontend_subnet_prefix]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Backend Subnet (Private App Service)
resource "azurerm_subnet" "backend" {
  name                 = "${var.environment}-${var.project_name}-backend-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_config.backend_subnet_prefix]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Database Subnet (Private endpoints)
resource "azurerm_subnet" "database" {
  name                 = "${var.environment}-${var.project_name}-database-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_config.database_subnet_prefix]
}

# Storage Subnet (Private endpoints)
resource "azurerm_subnet" "storage" {
  name                 = "${var.environment}-${var.project_name}-storage-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_config.storage_subnet_prefix]
}

# Network Security Group for Frontend
resource "azurerm_network_security_group" "frontend" {
  name                = "${var.environment}-${var.project_name}-frontend-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTP/HTTPS inbound
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow communication to backend subnet
  security_rule {
    name                       = "AllowBackendCommunication"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.subnet_config.frontend_subnet_prefix
    destination_address_prefix = var.subnet_config.backend_subnet_prefix
  }

  tags = var.tags
}

# Network Security Group for Backend
resource "azurerm_network_security_group" "backend" {
  name                = "${var.environment}-${var.project_name}-backend-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow communication from frontend subnet
  security_rule {
    name                       = "AllowFrontendCommunication"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.subnet_config.frontend_subnet_prefix
    destination_address_prefix = var.subnet_config.backend_subnet_prefix
  }

  # Allow communication to database subnet
  security_rule {
    name                       = "AllowDatabaseCommunication"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.subnet_config.backend_subnet_prefix
    destination_address_prefix = var.subnet_config.database_subnet_prefix
  }

  # Allow communication to storage subnet
  security_rule {
    name                       = "AllowStorageCommunication"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.subnet_config.backend_subnet_prefix
    destination_address_prefix = var.subnet_config.storage_subnet_prefix
  }

  tags = var.tags
}

# Network Security Group for Database
resource "azurerm_network_security_group" "database" {
  name                = "${var.environment}-${var.project_name}-database-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow SQL communication from backend subnet only
  security_rule {
    name                       = "AllowBackendSQL"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.subnet_config.backend_subnet_prefix
    destination_address_prefix = var.subnet_config.database_subnet_prefix
  }

  tags = var.tags
}

# Network Security Group for Storage
resource "azurerm_network_security_group" "storage" {
  name                = "${var.environment}-${var.project_name}-storage-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTPS communication from backend subnet only
  security_rule {
    name                       = "AllowBackendHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.subnet_config.backend_subnet_prefix
    destination_address_prefix = var.subnet_config.storage_subnet_prefix
  }

  tags = var.tags
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "frontend" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}

resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = azurerm_subnet.database.id
  network_security_group_id = azurerm_network_security_group.database.id
}

resource "azurerm_subnet_network_security_group_association" "storage" {
  subnet_id                 = azurerm_subnet.storage.id
  network_security_group_id = azurerm_network_security_group.storage.id
}

# Private DNS Zone for SQL Database
resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Link Private DNS Zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "${var.environment}-${var.project_name}-sql-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "${var.environment}-${var.project_name}-blob-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false

  tags = var.tags
}
