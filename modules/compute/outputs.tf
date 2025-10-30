output "frontend_app_service_id" {
  description = "ID of the frontend App Service"
  value       = azurerm_linux_web_app.frontend.id
}

output "backend_app_service_id" {
  description = "ID of the backend App Service"
  value       = azurerm_linux_web_app.backend.id
}

output "frontend_app_service_url" {
  description = "URL of the frontend App Service"
  value       = "https://${azurerm_linux_web_app.frontend.default_hostname}"
}

output "backend_app_service_url" {
  description = "URL of the backend App Service"
  value       = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "frontend_app_service_name" {
  description = "Name of the frontend App Service"
  value       = azurerm_linux_web_app.frontend.name
}

output "backend_app_service_name" {
  description = "Name of the backend App Service"
  value       = azurerm_linux_web_app.backend.name
}

output "frontend_managed_identity_principal_id" {
  description = "Principal ID of the frontend App Service managed identity"
  value       = azurerm_linux_web_app.frontend.identity[0].principal_id
}

output "backend_managed_identity_principal_id" {
  description = "Principal ID of the backend App Service managed identity"
  value       = azurerm_linux_web_app.backend.identity[0].principal_id
}
