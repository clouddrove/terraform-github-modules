mock_provider "github" {}

run "creates_a_runner_group" {
  command = plan

  variables {
    runner_groups = {
      "self-hosted-prod" = {
        visibility              = "selected"
        selected_repository_ids = [1, 2]
      }
    }
  }

  assert {
    condition     = length(github_actions_runner_group.this) == 1
    error_message = "Expected one runner group."
  }
}

run "rejects_an_invalid_allowed_actions_value" {
  command = plan

  variables {
    organization_permissions = {
      allowed_actions      = "everything"
      enabled_repositories = "all"
    }
  }

  expect_failures = [var.organization_permissions]
}

run "sets_the_repository_oidc_template" {
  command = plan

  variables {
    repository                 = "api"
    repository_oidc_claim_keys = ["repo", "context", "job_workflow_ref"]
  }

  assert {
    condition     = length(github_actions_repository_oidc_subject_claim_customization_template.this) == 1
    error_message = "Expected one repository OIDC template."
  }
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled = false
    runner_groups = {
      "self-hosted-prod" = { visibility = "all" }
    }
  }

  assert {
    condition     = length(github_actions_runner_group.this) == 0
    error_message = "enabled = false must create no resources."
  }
}
