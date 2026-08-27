##-----------------------------------------------------------------------------
## Generated secrets. Rotation is driven by time_rotating when rotation_days
## is set; without it a generated value is stable for the life of the state.
##-----------------------------------------------------------------------------
resource "time_rotating" "this" {
  for_each = var.enabled ? {
    for k, v in var.secrets : k => v.generate.rotation_days
    if v.generate != null && v.generate.rotation_days != null
  } : {}

  rotation_days = each.value
}

resource "random_password" "this" {
  for_each = var.enabled ? { for k, v in var.secrets : k => v if v.generate != null } : {}

  length           = each.value.generate.length
  special          = each.value.generate.special
  override_special = each.value.generate.override_special

  keepers = try(
    { rotated_at = time_rotating.this[each.key].rotation_rfc3339 },
    null
  )
}

##-----------------------------------------------------------------------------
## Actions secrets.
##-----------------------------------------------------------------------------
resource "github_actions_secret" "this" {
  for_each = nonsensitive(toset(keys(local.actions_repo)))

  repository  = local.actions_repo[each.value].repository
  secret_name = local.actions_repo[each.value].name
  value       = sensitive(local.value_for[local.actions_repo[each.value].name])
}

resource "github_actions_organization_secret" "this" {
  for_each = nonsensitive(toset(keys(local.actions_org)))

  secret_name             = each.value
  visibility              = var.targets.organization.visibility
  selected_repository_ids = var.targets.organization.visibility == "selected" ? [for r in data.github_repository.selected : r.repo_id] : null
  value                   = sensitive(local.value_for[each.value])
}

resource "github_actions_environment_secret" "this" {
  for_each = nonsensitive(toset(keys(local.actions_env)))

  repository  = local.actions_env[each.value].repository
  environment = local.actions_env[each.value].environment
  secret_name = local.actions_env[each.value].name
  value       = sensitive(local.value_for[local.actions_env[each.value].name])
}

##-----------------------------------------------------------------------------
## Dependabot secrets. No environment scope exists in the GitHub API.
##-----------------------------------------------------------------------------
resource "github_dependabot_secret" "this" {
  for_each = nonsensitive(toset(keys(local.dependabot_repo)))

  repository  = local.dependabot_repo[each.value].repository
  secret_name = local.dependabot_repo[each.value].name
  value       = sensitive(local.value_for[local.dependabot_repo[each.value].name])
}

resource "github_dependabot_organization_secret" "this" {
  for_each = nonsensitive(toset(keys(local.dependabot_org)))

  secret_name             = each.value
  visibility              = var.targets.organization.visibility
  selected_repository_ids = var.targets.organization.visibility == "selected" ? [for r in data.github_repository.selected : r.repo_id] : null
  value                   = sensitive(local.value_for[each.value])
}

##-----------------------------------------------------------------------------
## Codespaces secrets. No environment scope exists in the GitHub API.
## These two resources still use `plaintext_value`: unlike the actions and
## dependabot resources above, they have no `value` attribute in provider
## 6.13.0 and their `plaintext_value` is not deprecated.
##-----------------------------------------------------------------------------
resource "github_codespaces_secret" "this" {
  for_each = nonsensitive(toset(keys(local.codespaces_repo)))

  repository      = local.codespaces_repo[each.value].repository
  secret_name     = local.codespaces_repo[each.value].name
  plaintext_value = sensitive(local.value_for[local.codespaces_repo[each.value].name])
}

resource "github_codespaces_organization_secret" "this" {
  for_each = nonsensitive(toset(keys(local.codespaces_org)))

  secret_name             = each.value
  visibility              = var.targets.organization.visibility
  selected_repository_ids = var.targets.organization.visibility == "selected" ? [for r in data.github_repository.selected : r.repo_id] : null
  plaintext_value         = sensitive(local.value_for[each.value])
}

##-----------------------------------------------------------------------------
## Variables. Not encrypted by GitHub and visible in workflow logs.
##-----------------------------------------------------------------------------
resource "github_actions_variable" "this" {
  for_each = nonsensitive(toset(keys(local.variables_repo)))

  repository    = local.variables_repo[each.value].repository
  variable_name = local.variables_repo[each.value].name
  value         = local.value_for[local.variables_repo[each.value].name]
}

resource "github_actions_organization_variable" "this" {
  for_each = nonsensitive(toset(keys(local.variables_org)))

  variable_name           = each.value
  visibility              = var.targets.organization.visibility
  selected_repository_ids = var.targets.organization.visibility == "selected" ? [for r in data.github_repository.selected : r.repo_id] : null
  value                   = local.value_for[each.value]
}

resource "github_actions_environment_variable" "this" {
  for_each = nonsensitive(toset(keys(local.variables_env)))

  repository    = local.variables_env[each.value].repository
  environment   = local.variables_env[each.value].environment
  variable_name = local.variables_env[each.value].name
  value         = local.value_for[local.variables_env[each.value].name]
}

##-----------------------------------------------------------------------------
## Repository IDs for organization secrets with selected visibility.
##-----------------------------------------------------------------------------
data "github_repository" "selected" {
  for_each = local.org_enabled && var.targets.organization.visibility == "selected" ? toset(var.targets.organization.selected_repositories) : toset([])

  name = each.value
}
