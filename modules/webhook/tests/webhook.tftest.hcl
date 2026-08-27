mock_provider "github" {}

run "creates_a_repository_webhook" {
  command = plan

  variables {
    repository = "api"
    webhooks = {
      ci = {
        url    = "https://ci.example.com/hook"
        events = ["push", "pull_request"]
      }
    }
  }

  assert {
    condition     = length(github_repository_webhook.this) == 1
    error_message = "Expected one repository webhook."
  }
}

run "creates_an_organization_webhook" {
  command = plan

  variables {
    scope = "organization"
    webhooks = {
      audit = {
        url    = "https://siem.example.com/hook"
        events = ["*"]
      }
    }
  }

  assert {
    condition     = length(github_organization_webhook.this) == 1
    error_message = "Expected one organization webhook."
  }
}

run "rejects_a_non_https_url" {
  command = plan

  variables {
    repository = "api"
    webhooks = {
      bad = {
        url    = "http://insecure.example.com/hook"
        events = ["push"]
      }
    }
  }

  expect_failures = [var.webhooks]
}

run "rejects_an_empty_events_list" {
  command = plan

  variables {
    repository = "api"
    webhooks = {
      bad = {
        url    = "https://ci.example.com/hook"
        events = []
      }
    }
  }

  expect_failures = [var.webhooks]
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled    = false
    repository = "api"
    webhooks = {
      ci = { url = "https://ci.example.com/hook", events = ["push"] }
    }
  }

  assert {
    condition     = length(github_repository_webhook.this) == 0
    error_message = "enabled = false must create no resources."
  }
}
