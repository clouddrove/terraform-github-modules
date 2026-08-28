##-----------------------------------------------------------------------------
## Baseline composite. One repository, its ruleset, its environments, and the
## secrets published to them.
##-----------------------------------------------------------------------------
module "repository" {
  source = "./modules/repository"

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby

  description          = var.description
  visibility           = var.visibility
  topics               = var.topics
  files                = var.files
  issue_labels         = var.issue_labels
  collaborators        = var.collaborators
  vulnerability_alerts = var.vulnerability_alerts
  archive_on_destroy   = var.archive_on_destroy
}

module "ruleset" {
  source = "./modules/ruleset"

  enabled     = var.enabled && var.ruleset != null
  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby

  scope        = "repository"
  repository   = local.ruleset_repository
  ruleset_name = try(var.ruleset.ruleset_name, null)
  target       = try(var.ruleset.target, "branch")
  enforcement  = try(var.ruleset.enforcement, "active")
  conditions   = try(var.ruleset.conditions, null)
  rules        = try(var.ruleset.rules, {})
}

module "environments" {
  source   = "./modules/environment"
  for_each = var.enabled ? var.environments : {}

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby

  repository               = module.repository.repository_name
  environment_name         = each.key
  wait_timer               = each.value.wait_timer
  reviewers                = each.value.reviewers
  deployment_branch_policy = each.value.deployment_branch_policy
  branch_patterns          = each.value.branch_patterns
}

module "secrets" {
  source = "./modules/secrets"

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby

  secrets = var.secrets
  kinds   = var.secret_kinds

  targets = {
    repositories = local.secret_repositories
    environments = [for k, m in module.environments : m.secrets_target]
  }
}
