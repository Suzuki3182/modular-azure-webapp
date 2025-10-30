variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone for SQL"
  type        = string
}

variable "database_config" {
  description = "Configuration for Azure SQL Database"
  type = object({
    sku_name                     = string
    max_size_gb                  = number
    auto_pause_delay_in_minutes  = number
    min_capacity                 = number
  })
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
