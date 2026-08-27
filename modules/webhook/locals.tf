locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  repository_webhooks   = var.enabled && var.scope == "repository" ? var.webhooks : {}
  organization_webhooks = var.enabled && var.scope == "organization" ? var.webhooks : {}
}
