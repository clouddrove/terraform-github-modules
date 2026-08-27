## Repository ruleset. The provider requires a ref_name block inside
## conditions, so conditions is rendered only when ref_name is supplied.
resource "github_repository_ruleset" "this" {
  count = local.repository_ruleset_count

  name        = var.ruleset_name
  repository  = var.repository
  target      = var.target
  enforcement = var.enforcement

  dynamic "conditions" {
    for_each = try(var.conditions.ref_name, null) != null ? [var.conditions] : []
    content {
      ref_name {
        include = conditions.value.ref_name.include
        exclude = conditions.value.ref_name.exclude
      }
    }
  }

  dynamic "bypass_actors" {
    for_each = var.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    creation                = var.rules.creation
    update                  = var.rules.update
    deletion                = var.rules.deletion
    required_linear_history = var.rules.required_linear_history
    required_signatures     = var.rules.required_signatures
    non_fast_forward        = var.rules.non_fast_forward

    dynamic "pull_request" {
      for_each = var.rules.pull_request != null ? [var.rules.pull_request] : []
      content {
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_approving_review_count   = pull_request.value.required_approving_review_count
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
      }
    }

    dynamic "required_status_checks" {
      for_each = var.rules.required_status_checks != null ? [var.rules.required_status_checks] : []
      content {
        strict_required_status_checks_policy = required_status_checks.value.strict_required_status_checks_policy

        dynamic "required_check" {
          for_each = required_status_checks.value.required_check
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }
  }
}

## Organization ruleset. Same rule surface as the repository ruleset, with no
## repository argument, and a repository_name condition that only exists at
## organization scope.
resource "github_organization_ruleset" "this" {
  count = local.organization_ruleset_count

  name        = var.ruleset_name
  target      = var.target
  enforcement = var.enforcement

  dynamic "conditions" {
    for_each = var.conditions != null ? [var.conditions] : []
    content {
      dynamic "ref_name" {
        for_each = conditions.value.ref_name != null ? [conditions.value.ref_name] : []
        content {
          include = ref_name.value.include
          exclude = ref_name.value.exclude
        }
      }

      dynamic "repository_name" {
        for_each = conditions.value.repository_name != null ? [conditions.value.repository_name] : []
        content {
          include   = repository_name.value.include
          exclude   = repository_name.value.exclude
          protected = repository_name.value.protected
        }
      }
    }
  }

  dynamic "bypass_actors" {
    for_each = var.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    creation                = var.rules.creation
    update                  = var.rules.update
    deletion                = var.rules.deletion
    required_linear_history = var.rules.required_linear_history
    required_signatures     = var.rules.required_signatures
    non_fast_forward        = var.rules.non_fast_forward

    dynamic "pull_request" {
      for_each = var.rules.pull_request != null ? [var.rules.pull_request] : []
      content {
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_approving_review_count   = pull_request.value.required_approving_review_count
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
      }
    }

    dynamic "required_status_checks" {
      for_each = var.rules.required_status_checks != null ? [var.rules.required_status_checks] : []
      content {
        strict_required_status_checks_policy = required_status_checks.value.strict_required_status_checks_policy

        dynamic "required_check" {
          for_each = required_status_checks.value.required_check
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }
  }
}

## Classic branch protection for repositories that have not migrated to
## rulesets. repository_id accepts a repository name or a node ID.
resource "github_branch_protection" "this" {
  for_each = var.enabled ? var.branch_protection : {}

  repository_id           = var.repository
  pattern                 = each.value.pattern
  enforce_admins          = each.value.enforce_admins
  require_signed_commits  = each.value.require_signed_commits
  required_linear_history = each.value.required_linear_history
  allows_deletions        = each.value.allows_deletions
  allows_force_pushes     = each.value.allows_force_pushes

  required_pull_request_reviews {
    required_approving_review_count = each.value.required_approving_review_count
  }
}
