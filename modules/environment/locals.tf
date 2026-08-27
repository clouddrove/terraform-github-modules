locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  enabled_count = var.enabled ? 1 : 0

  branch_policies = var.enabled ? { for p in var.branch_patterns : p => p } : {}
  tag_policies    = var.enabled ? { for p in var.tag_patterns : p => p } : {}
}
