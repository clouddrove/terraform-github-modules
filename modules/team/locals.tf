locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  enabled_count = var.enabled ? 1 : 0
  team_slug     = var.enabled ? github_team.this[0].slug : null
}
