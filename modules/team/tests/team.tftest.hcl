mock_provider "github" {}

run "creates_a_team" {
  command = plan

  variables {
    name        = "platform"
    description = "Platform engineering"
  }

  assert {
    condition     = length(github_team.this) == 1
    error_message = "Expected one team."
  }
}

run "rejects_an_invalid_privacy" {
  command = plan

  variables {
    name    = "platform"
    privacy = "hidden"
  }

  expect_failures = [var.privacy]
}

run "rejects_an_invalid_member_role" {
  command = plan

  variables {
    name    = "platform"
    members = { alice = "owner" }
  }

  expect_failures = [var.members]
}

run "rejects_an_invalid_repository_permission" {
  command = plan

  variables {
    name         = "platform"
    repositories = { api = "superuser" }
  }

  expect_failures = [var.repositories]
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled = false
    name    = "platform"
  }

  assert {
    condition     = length(github_team.this) == 0
    error_message = "enabled = false must create no resources."
  }
}
