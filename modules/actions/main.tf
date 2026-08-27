# Organization-wide Actions permissions. Controls which actions and reusable
# workflows may run, and which repositories have Actions enabled at all.
resource "github_actions_organization_permissions" "this" {
  count = local.org_permissions_count

  allowed_actions      = var.organization_permissions.allowed_actions
  enabled_repositories = var.organization_permissions.enabled_repositories

  dynamic "allowed_actions_config" {
    for_each = var.organization_permissions.allowed_actions == "selected" && var.organization_permissions.allowed_actions_config != null ? [var.organization_permissions.allowed_actions_config] : []
    content {
      github_owned_allowed = allowed_actions_config.value.github_owned_allowed
      verified_allowed     = allowed_actions_config.value.verified_allowed
      patterns_allowed     = allowed_actions_config.value.patterns_allowed
    }
  }

  dynamic "enabled_repositories_config" {
    for_each = var.organization_permissions.enabled_repositories == "selected" ? [var.organization_permissions.enabled_repository_ids] : []
    content {
      repository_ids = enabled_repositories_config.value
    }
  }
}

# Repository-scoped Actions permissions.
resource "github_actions_repository_permissions" "this" {
  count = local.repo_permissions_count

  repository      = var.repository
  allowed_actions = var.repository_permissions.allowed_actions
  enabled         = var.repository_permissions.enabled

  dynamic "allowed_actions_config" {
    for_each = var.repository_permissions.allowed_actions == "selected" && var.repository_permissions.allowed_actions_config != null ? [var.repository_permissions.allowed_actions_config] : []
    content {
      github_owned_allowed = allowed_actions_config.value.github_owned_allowed
      verified_allowed     = allowed_actions_config.value.verified_allowed
      patterns_allowed     = allowed_actions_config.value.patterns_allowed
    }
  }
}

# Self-hosted runner groups, keyed by group name.
resource "github_actions_runner_group" "this" {
  for_each = var.enabled ? var.runner_groups : {}

  name       = each.key
  visibility = each.value.visibility

  # GitHub rejects a repository selection unless visibility is "selected".
  selected_repository_ids = each.value.visibility == "selected" ? each.value.selected_repository_ids : null

  allows_public_repositories = each.value.allows_public_repositories
  restricted_to_workflows    = each.value.restricted_to_workflows

  # Likewise, a workflow allow list only applies when the group is restricted.
  selected_workflows = each.value.restricted_to_workflows ? each.value.selected_workflows : null
}

# Who may use a private repository's workflows from outside the repository.
resource "github_actions_repository_access_level" "this" {
  count = local.access_level_count

  repository   = var.repository
  access_level = var.repository_access_level
}

# OIDC subject claim customization. This is how a consumer federates into AWS
# or Azure without storing a long-lived credential as a GitHub secret. See the
# module README for the comparison with modules/secrets.
resource "github_actions_organization_oidc_subject_claim_customization_template" "this" {
  count = local.org_oidc_count

  include_claim_keys = var.organization_oidc_claim_keys
}

resource "github_actions_repository_oidc_subject_claim_customization_template" "this" {
  count = local.repo_oidc_count

  repository         = var.repository
  use_default        = false
  include_claim_keys = var.repository_oidc_claim_keys
}
