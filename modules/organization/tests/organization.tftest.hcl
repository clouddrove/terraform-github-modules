mock_provider "github" {}

run "manages_organization_settings" {
  command = plan

  variables {
    billing_email = "billing@clouddrove.com"
    company       = "CloudDrove"
  }

  assert {
    condition     = length(github_organization_settings.this) == 1
    error_message = "Expected organization settings to be managed."
  }
}

run "rejects_an_invalid_member_role" {
  command = plan

  variables {
    billing_email = "billing@clouddrove.com"
    members       = { alice = "superadmin" }
  }

  expect_failures = [var.members]
}

run "rejects_an_invalid_default_repository_permission" {
  command = plan

  variables {
    billing_email                 = "billing@clouddrove.com"
    default_repository_permission = "everything"
  }

  expect_failures = [var.default_repository_permission]
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled       = false
    billing_email = "billing@clouddrove.com"
  }

  assert {
    condition     = length(github_organization_settings.this) == 0
    error_message = "enabled = false must create no resources."
  }
}
