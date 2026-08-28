mock_provider "github" {}
mock_provider "random" {}
mock_provider "time" {}

run "creates_a_repository_with_a_ruleset_and_secrets" {
  command = plan

  variables {
    name        = "api"
    environment = "prod"
    description = "API service"

    ruleset = {
      ruleset_name = "main-protection"
      rules = {
        deletion         = true
        non_fast_forward = true
        pull_request = {
          required_approving_review_count = 2
        }
      }
    }

    secrets = {
      SERVICE_TOKEN = { generate = { length = 40, special = false } }
    }
  }

  assert {
    condition     = module.repository.repository_name == "api-prod"
    error_message = "Repository name must be composed from label_order."
  }

  assert {
    condition     = length(module.secrets.secret_names) == 1
    error_message = "Expected one published secret."
  }
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled = false
    name    = "api"
  }

  assert {
    condition     = module.repository.repository_name == null
    error_message = "enabled = false must create no repository."
  }
}
