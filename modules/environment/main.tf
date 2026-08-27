## Environment and its protection rules. Environment secrets and variables are
## owned by the secrets module so that secret material has exactly one writer.
resource "github_repository_environment" "this" {
  count = local.enabled_count

  repository          = var.repository
  environment         = var.environment_name
  wait_timer          = var.wait_timer
  prevent_self_review = var.prevent_self_review
  can_admins_bypass   = var.can_admins_bypass

  dynamic "reviewers" {
    for_each = length(var.reviewers.users) > 0 || length(var.reviewers.teams) > 0 ? [var.reviewers] : []
    content {
      users = reviewers.value.users
      teams = reviewers.value.teams
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = var.deployment_branch_policy != null ? [var.deployment_branch_policy] : []
    content {
      protected_branches     = deployment_branch_policy.value.protected_branches
      custom_branch_policies = deployment_branch_policy.value.custom_branch_policies
    }
  }
}

## Custom deployment policies. Valid only when the environment sets
## custom_branch_policies, which the variable validations enforce.
resource "github_repository_environment_deployment_policy" "this" {
  for_each = local.branch_policies

  repository     = var.repository
  environment    = github_repository_environment.this[0].environment
  branch_pattern = each.value
}

resource "github_repository_environment_deployment_policy" "tag" {
  for_each = local.tag_policies

  repository  = var.repository
  environment = github_repository_environment.this[0].environment
  tag_pattern = each.value
}
