locals {
  ## label_order selects which parts compose the module id. managedby is
  ## available as a part but is not included by the default label_order.
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  repository_ruleset_count   = var.enabled && var.scope == "repository" && var.ruleset_name != null ? 1 : 0
  organization_ruleset_count = var.enabled && var.scope == "organization" && var.ruleset_name != null ? 1 : 0
}
