provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "postgresql" {
  host            = var.shared_postgres_flexible_server_fqdn
  port            = 5432
  database        = "postgres"
  username        = var.shared_postgres_flexible_server_admin_username
  password        = var.shared_postgres_flexible_server_admin_password
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
}

resource "azurerm_resource_group" "core_audits_test" {
  name     = var.resource_group_name
  location = var.location
}