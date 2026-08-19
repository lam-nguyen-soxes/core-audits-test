variable "postgres_collation" {
  description = "Collation of the database"
  type        = string
  default     = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_database" "postgres_core_audits" {
  name      = "${lower(var.environment)}-core-audits"
  server_id = var.shared_postgres_flexible_server_id
  collation = var.postgres_collation
  charset   = "UTF8"

  lifecycle {
    prevent_destroy = true
  }
}

resource "postgresql_role" "core_audits_access_role" {
  name  = "core_audits_access_role"
  login = false
}

resource "random_password" "core_audits_app_user_password" {
  length  = 24
  special = false
  upper   = false
  numeric = true
  lower   = true
}

resource "postgresql_role" "core_audits_app_user" {
  name     = "${lower(var.environment)}_core_audits_user"
  login    = true
  password = random_password.core_audits_app_user_password.result
  roles    = [postgresql_role.core_audits_access_role.name]
}

resource "postgresql_grant" "core_audits_connect" {
  database    = azurerm_postgresql_flexible_server_database.postgres_core_audits.name
  role        = postgresql_role.core_audits_app_user.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

# Core-Audits - Grant schema usage
resource "postgresql_grant" "core_audits_schema_usage" {
  database    = azurerm_postgresql_flexible_server_database.postgres_core_audits.name
  role        = postgresql_role.core_audits_access_role.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}

# Core-Audits - Grant default privileges for future tables
resource "postgresql_default_privileges" "core_audits_tables" {
  database    = azurerm_postgresql_flexible_server_database.postgres_core_audits.name
  role        = postgresql_role.core_audits_access_role.name
  schema      = "public"
  owner       = postgresql_role.core_audits_app_user.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_grant.core_audits_schema_usage]
}

# Core-Audits - Grant default privileges for sequences (for auto-increment)
resource "postgresql_default_privileges" "core_audits_sequences" {
  database    = azurerm_postgresql_flexible_server_database.postgres_core_audits.name
  role        = postgresql_role.core_audits_access_role.name
  schema      = "public"
  owner       = postgresql_role.core_audits_app_user.name
  object_type = "sequence"
  privileges  = ["SELECT", "UPDATE", "USAGE"]
  depends_on = [postgresql_default_privileges.core_audits_tables]
}

# Core-Audits - Grant on existing tables (if any exist)
resource "postgresql_grant" "core_audits_existing_tables" {
  database    = azurerm_postgresql_flexible_server_database.postgres_core_audits.name
  role        = postgresql_role.core_audits_access_role.name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_default_privileges.core_audits_sequences]
}

# Core-Audits - Grant on existing sequences
resource "postgresql_grant" "core_audits_existing_sequences" {
  database    = azurerm_postgresql_flexible_server_database.postgres_core_audits.name
  role        = postgresql_role.core_audits_access_role.name
  schema      = "public"
  object_type = "sequence"
  privileges  = ["SELECT", "UPDATE", "USAGE"]
  depends_on = [postgresql_grant.core_audits_existing_tables]
}

resource "azurerm_postgresql_flexible_server_database" "postgres_audit_trail" {
  name      = "${lower(var.environment)}-audit-trail"
  server_id = var.shared_postgres_flexible_server_id
  collation = var.postgres_collation
  charset   = "UTF8"

  lifecycle {
    prevent_destroy = true
  }
}

resource "postgresql_role" "audit_trail_access_role" {
  name  = "audit_trail_access_role"
  login = false
}

resource "random_password" "audit_trail_app_user_password" {
  length  = 24
  special = false
  upper   = false
  numeric = true
  lower   = true
}

resource "postgresql_role" "audit_trail_app_user" {
  name     = "${lower(var.environment)}_audit_trail_user"
  login    = true
  password = random_password.audit_trail_app_user_password.result
  roles    = [postgresql_role.audit_trail_access_role.name]
}

resource "postgresql_grant" "audit_trail_connect" {
  database    = azurerm_postgresql_flexible_server_database.postgres_audit_trail.name
  role        = postgresql_role.audit_trail_app_user.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_schema" "audit_trail_core_audits_trail" {
  name     = "CoreAuditsTrail"
  database = azurerm_postgresql_flexible_server_database.postgres_audit_trail.name
  owner    = postgresql_role.audit_trail_app_user.name

  depends_on = [postgresql_grant.audit_trail_connect]
}

resource "postgresql_grant" "audit_trail_schema_usage" {
  database    = azurerm_postgresql_flexible_server_database.postgres_audit_trail.name
  role        = postgresql_role.audit_trail_access_role.name
  schema      = postgresql_schema.audit_trail_core_audits_trail.name
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}

resource "postgresql_default_privileges" "audit_trail_tables" {
  database    = azurerm_postgresql_flexible_server_database.postgres_audit_trail.name
  role        = postgresql_role.audit_trail_access_role.name
  schema      = postgresql_schema.audit_trail_core_audits_trail.name
  owner       = postgresql_role.audit_trail_app_user.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_grant.audit_trail_schema_usage]
}

resource "postgresql_default_privileges" "audit_trail_sequences" {
  database    = azurerm_postgresql_flexible_server_database.postgres_audit_trail.name
  role        = postgresql_role.audit_trail_access_role.name
  schema      = postgresql_schema.audit_trail_core_audits_trail.name
  owner       = postgresql_role.audit_trail_app_user.name
  object_type = "sequence"
  privileges  = ["SELECT", "UPDATE", "USAGE"]
  depends_on = [postgresql_default_privileges.audit_trail_tables]
}

resource "postgresql_grant" "audit_trail_existing_tables" {
  database    = azurerm_postgresql_flexible_server_database.postgres_audit_trail.name
  role        = postgresql_role.audit_trail_access_role.name
  schema      = postgresql_schema.audit_trail_core_audits_trail.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [postgresql_default_privileges.audit_trail_sequences]
}

resource "postgresql_grant" "audit_trail_existing_sequences" {
  database    = azurerm_postgresql_flexible_server_database.postgres_audit_trail.name
  role        = postgresql_role.audit_trail_access_role.name
  schema      = postgresql_schema.audit_trail_core_audits_trail.name
  object_type = "sequence"
  privileges  = ["SELECT", "UPDATE", "USAGE"]
  depends_on = [postgresql_grant.audit_trail_existing_tables]
}