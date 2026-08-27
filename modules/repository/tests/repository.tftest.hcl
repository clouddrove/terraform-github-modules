mock_provider "github" {}

run "creates_a_repository" {
  command = plan

  variables {
    name        = "api"
    environment = "prod"
    description = "API service"
  }

  assert {
    condition     = length(github_repository.this) == 1
    error_message = "Expected one repository."
  }

  assert {
    condition     = github_repository.this[0].name == "api-prod"
    error_message = "Repository name must be composed from label_order."
  }
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled = false
    name    = "api"
  }

  assert {
    condition     = length(github_repository.this) == 0
    error_message = "enabled = false must create no resources."
  }
}

run "rejects_an_invalid_visibility" {
  command = plan

  variables {
    name       = "api"
    visibility = "secret"
  }

  expect_failures = [var.visibility]
}

run "creates_issue_labels" {
  command = plan

  variables {
    name = "api"
    issue_labels = {
      bug = { color = "d73a4a", description = "Something is broken" }
    }
  }

  assert {
    condition     = length(github_issue_label.this) == 1
    error_message = "Expected one issue label."
  }
}

run "creates_repository_files" {
  command = plan

  variables {
    name = "api"
    files = {
      "CODEOWNERS" = { content = "* @clouddrove/platform" }
    }
  }

  assert {
    condition     = length(github_repository_file.this) == 1
    error_message = "Expected one repository file."
  }
}
