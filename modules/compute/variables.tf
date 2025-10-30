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

variable "frontend_subnet_id" {
  description = "ID of the frontend subnet"
  type        = string
}

variable "backend_subnet_id" {
  description = "ID of the backend subnet"
  type        = string
}

variable "app_service_config" {
  description = "Configuration for App Services"
  type = object({
    frontend_sku_name = string
    backend_sku_name  = string
    frontend_os_type  = string
    backend_os_type   = string
  })
}

variable "sql_connection_string" {
  description = "SQL database connection string"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "storage_account_key" {
  description = "Primary access key for storage account"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
