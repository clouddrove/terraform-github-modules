locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  resolved = { for k, v in data.azurerm_key_vault_secret.this : k => v.value }
}
