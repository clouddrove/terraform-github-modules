mock_provider "github" {}

run "creates_a_repository_ruleset" {
  command = plan

  variables {
    repository   = "api"
    ruleset_name = "main-protection"
    target       = "branch"
    conditions = {
      ref_name = { include = ["~DEFAULT_BRANCH"], exclude = [] }
    }
    rules = {
      deletion         = true
      non_fast_forward = true
      pull_request = {
        required_approving_review_count = 2
      }
    }
  }

  assert {
    condition     = length(github_repository_ruleset.this) == 1
    error_message = "Expected one repository ruleset."
  }
}

run "rejects_an_invalid_target" {
  command = plan

  variables {
    repository   = "api"
    ruleset_name = "bad"
    target       = "wrong"
  }

  expect_failures = [var.target]
}

run "rejects_an_invalid_enforcement" {
  command = plan

  variables {
    repository   = "api"
    ruleset_name = "bad"
    enforcement  = "sometimes"
  }

  expect_failures = [var.enforcement]
}

run "requires_a_repository_for_repository_scope" {
  command = plan

  variables {
    scope        = "repository"
    repository   = null
    ruleset_name = "bad"
  }

  expect_failures = [var.repository]
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled      = false
    repository   = "api"
    ruleset_name = "main-protection"
  }

  assert {
    condition     = length(github_repository_ruleset.this) == 0
    error_message = "enabled = false must create no resources."
  }
}
