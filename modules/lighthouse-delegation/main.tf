resource "azurerm_lighthouse_definition" "this" {
  name               = var.delegation_name
  description        = var.delegation_description
  managing_tenant_id = var.managing_tenant_id
  scope              = var.scope

  dynamic "authorization" {
    for_each = var.authorizations
    content {
      principal_id                  = authorization.value.principal_id
      principal_display_name        = authorization.value.principal_display_name
      role_definition_id            = authorization.value.role_definition_id
      delegated_role_definition_ids = authorization.value.delegated_role_definition_ids
    }
  }
}

resource "azurerm_lighthouse_assignment" "this" {
  scope                    = var.scope
  lighthouse_definition_id = azurerm_lighthouse_definition.this.id
}
