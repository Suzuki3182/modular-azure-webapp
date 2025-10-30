variable "environment" {
  description = "Environment name (e.g., cde, prod)"
  type        = string
  validation {
    condition     = contains(["cde", "prod", "dev", "staging"], var.environment)
    error_message = "Environment must be one of: cde, prod, dev, staging."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "webapp"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_config" {
  description = "Configuration for subnets"
  type = object({
    frontend_subnet_prefix = string
    backend_subnet_prefix  = string
    database_subnet_prefix = string
    storage_subnet_prefix  = string
  })
  default = {
    frontend_subnet_prefix = "10.0.1.0/24"
    backend_subnet_prefix  = "10.0.2.0/24"
    database_subnet_prefix = "10.0.3.0/24"
    storage_subnet_prefix  = "10.0.4.0/24"
  }
}

variable "app_service_config" {
  description = "Configuration for App Services"
  type = object({
    frontend_sku_name = string
    backend_sku_name  = string
    frontend_os_type  = string
    backend_os_type   = string
  })
  default = {
    frontend_sku_name = "B1"
    backend_sku_name  = "B1"
    frontend_os_type  = "Linux"
    backend_os_type   = "Linux"
  }
}

variable "database_config" {
  description = "Configuration for Azure SQL Database"
  type = object({
    sku_name                    = string
    max_size_gb                 = number
    auto_pause_delay_in_minutes = number
    min_capacity                = number
  })
  default = {
    sku_name                    = "GP_S_Gen5_1"
    max_size_gb                 = 32
    auto_pause_delay_in_minutes = 60
    min_capacity                = 0.5
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "WebApp"
    ManagedBy = "Terraform"
  }
}
