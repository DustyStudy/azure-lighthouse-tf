module "lighthouse_delegation" {
  source = "./modules/lighthouse-delegation"

  scope                  = var.scope
  managing_tenant_id     = var.managing_tenant_id
  delegation_name        = var.delegation_name
  delegation_description = var.delegation_description
  authorizations         = var.authorizations
  tags                   = var.tags
}
