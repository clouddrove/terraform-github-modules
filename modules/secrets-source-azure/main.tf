data "azurerm_key_vault_secret" "this" {
  for_each = var.enabled ? var.secrets : {}

  key_vault_id = each.value.key_vault_id
  name         = each.value.name
  version      = each.value.version
}
