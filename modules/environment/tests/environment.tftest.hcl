mock_provider "github" {}

run "creates_an_environment" {
  command = plan

  variables {
    repository       = "api"
    environment_name = "prod"
  }

  assert {
    condition     = length(github_repository_environment.this) == 1
    error_message = "Expected one environment."
  }
}

run "rejects_a_wait_timer_above_the_api_maximum" {
  command = plan

  variables {
    repository       = "api"
    environment_name = "prod"
    wait_timer       = 50000
  }

  expect_failures = [var.wait_timer]
}

run "creates_deployment_branch_policies" {
  command = plan

  variables {
    repository       = "api"
    environment_name = "prod"
    deployment_branch_policy = {
      protected_branches     = false
      custom_branch_policies = true
    }
    branch_patterns = ["main", "release/*"]
  }

  assert {
    condition     = length(github_repository_environment_deployment_policy.this) == 2
    error_message = "Expected one policy per branch pattern."
  }
}

run "rejects_branch_patterns_without_custom_branch_policies" {
  command = plan

  variables {
    repository       = "api"
    environment_name = "prod"
    deployment_branch_policy = {
      protected_branches     = true
      custom_branch_policies = false
    }
    branch_patterns = ["main"]
  }

  expect_failures = [var.branch_patterns]
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled          = false
    repository       = "api"
    environment_name = "prod"
  }

  assert {
    condition     = length(github_repository_environment.this) == 0
    error_message = "enabled = false must create no resources."
  }
}
