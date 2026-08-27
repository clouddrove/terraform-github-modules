resource "github_organization_settings" "this" {
  count = local.settings_count

  billing_email                                                = var.billing_email
  company                                                      = var.company
  blog                                                         = var.blog
  email                                                        = var.email
  location                                                     = var.location
  description                                                  = var.organization_description
  default_repository_permission                                = var.default_repository_permission
  members_can_create_repositories                              = var.members_can_create_repositories
  members_can_create_public_repositories                       = var.members_can_create_public_repositories
  web_commit_signoff_required                                  = var.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = var.advanced_security_enabled_for_new_repositories
  dependabot_alerts_enabled_for_new_repositories               = var.dependabot_alerts_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories                 = var.secret_scanning_enabled_for_new_repositories
  secret_scanning_push_protection_enabled_for_new_repositories = var.secret_scanning_push_protection_enabled_for_new_repositories
}

resource "github_membership" "this" {
  for_each = var.enabled ? var.members : {}

  username = each.key
  role     = each.value
}

resource "github_organization_block" "this" {
  for_each = var.enabled ? toset(var.blocked_users) : toset([])

  username = each.value
}

resource "github_organization_repository_role" "this" {
  for_each = var.enabled ? var.custom_roles : {}

  name        = each.key
  description = each.value.description
  base_role   = each.value.base_role
  permissions = each.value.permissions
}

resource "github_organization_custom_properties" "this" {
  for_each = var.enabled ? var.custom_properties : {}

  property_name      = each.key
  value_type         = each.value.value_type
  required           = each.value.required
  default_value      = each.value.default_value
  description        = each.value.description
  allowed_values     = each.value.allowed_values
  values_editable_by = each.value.values_editable_by
}
