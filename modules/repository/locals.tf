locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  repository_name = var.enabled ? github_repository.this[0].name : null
  enabled_count   = var.enabled ? 1 : 0
}
