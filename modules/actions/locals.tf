locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  org_permissions_count  = var.enabled && var.organization_permissions != null ? 1 : 0
  repo_permissions_count = var.enabled && var.repository_permissions != null && var.repository != null ? 1 : 0
  org_oidc_count         = var.enabled && length(var.organization_oidc_claim_keys) > 0 ? 1 : 0
  repo_oidc_count        = var.enabled && length(var.repository_oidc_claim_keys) > 0 && var.repository != null ? 1 : 0
  access_level_count     = var.enabled && var.repository_access_level != null && var.repository != null ? 1 : 0
}
