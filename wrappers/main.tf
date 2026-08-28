##-----------------------------------------------------------------------------
## One call to the baseline root per entry in var.items. Values resolve in the
## order: the entry, then var.defaults, then the literal fallback here.
##-----------------------------------------------------------------------------
module "wrapper" {
  source = "../"

  for_each = var.items

  enabled      = try(each.value.enabled, var.defaults.enabled, true)
  name         = try(each.value.name, each.key)
  environment  = try(each.value.environment, var.defaults.environment, "")
  label_order  = try(each.value.label_order, var.defaults.label_order, ["name", "environment"])
  managedby    = try(each.value.managedby, var.defaults.managedby, "hello@clouddrove.com")
  description  = try(each.value.description, var.defaults.description, "")
  visibility   = try(each.value.visibility, var.defaults.visibility, "private")
  topics       = try(each.value.topics, var.defaults.topics, [])
  ruleset      = try(each.value.ruleset, var.defaults.ruleset, null)
  environments = try(each.value.environments, var.defaults.environments, {})
  secrets      = try(each.value.secrets, var.defaults.secrets, {})
  secret_kinds = try(each.value.secret_kinds, var.defaults.secret_kinds, ["actions"])
}
