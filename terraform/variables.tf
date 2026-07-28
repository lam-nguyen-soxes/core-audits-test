variable "subscription_id" {
  description = "The subscription ID for the Azure account."
  type        = string
}

# variable "resource_group_name" {
#   description = "The name of the resource group to create."
#   type        = string
# }

variable "location" {
  description = "The Azure region where the resource group will be created."
  type        = string
  default     = "Switzerland North"
}

variable "shared_postgres_flexible_server_fqdn" {
  description = "The fully qualified domain name (FQDN) of the shared PostgreSQL flexible server."
  type        = string
}

variable "shared_postgres_flexible_server_admin_username" {
  description = "The admin username for the shared PostgreSQL flexible server."
  type        = string
}

variable "shared_postgres_flexible_server_admin_password" {
  description = "The admin password for the shared PostgreSQL flexible server."
  type        = string
  sensitive   = true
}

variable "shared_postgres_flexible_server_id" {
  description = "The resource ID of the shared PostgreSQL flexible server."
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, test, prod)."
  type        = string
}