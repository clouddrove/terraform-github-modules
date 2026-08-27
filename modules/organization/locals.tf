locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  settings_count = var.enabled && var.manage_settings ? 1 : 0
}
