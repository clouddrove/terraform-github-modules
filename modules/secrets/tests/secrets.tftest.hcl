mock_provider "github" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  targets = {
    repositories = ["api"]
  }
}

run "accepts_a_direct_value" {
  command = plan

  variables {
    secrets = {
      RDS_PASSWORD = { value = "hunter2" }
    }
  }

  assert {
    condition     = length(github_actions_secret.this) == 1
    error_message = "Expected exactly one repository actions secret."
  }
}

run "rejects_lowercase_secret_name" {
  command = plan

  variables {
    secrets = {
      rds_password = { value = "hunter2" }
    }
  }

  expect_failures = [var.secrets]
}

run "rejects_github_prefixed_name" {
  command = plan

  variables {
    secrets = {
      GITHUB_TOKEN = { value = "hunter2" }
    }
  }

  expect_failures = [var.secrets]
}

run "rejects_both_value_and_generate" {
  command = plan

  variables {
    secrets = {
      TOKEN = { value = "hunter2", generate = { length = 16 } }
    }
  }

  expect_failures = [var.secrets]
}

run "rejects_neither_value_nor_generate" {
  command = plan

  variables {
    secrets = {
      TOKEN = {}
    }
  }

  expect_failures = [var.secrets]
}

run "rejects_generate_combined_with_as_variable" {
  command = plan

  variables {
    secrets = {
      TOKEN = { generate = { length = 16 }, as_variable = true }
    }
  }

  expect_failures = [var.secrets]
}

run "as_variable_writes_a_variable_not_a_secret" {
  command = plan

  variables {
    secrets = {
      DB_HOST = { value = "db.internal", as_variable = true }
    }
  }

  assert {
    condition     = length(github_actions_secret.this) == 0
    error_message = "as_variable entries must not create secrets."
  }

  assert {
    condition     = length(github_actions_variable.this) == 1
    error_message = "as_variable entries must create a variable."
  }
}

run "enabled_false_creates_nothing" {
  command = plan

  variables {
    enabled = false
    secrets = {
      RDS_PASSWORD = { value = "hunter2" }
    }
  }

  assert {
    condition     = length(github_actions_secret.this) == 0
    error_message = "enabled = false must create no resources."
  }
}

run "dependabot_kind_creates_dependabot_secret" {
  command = plan

  variables {
    kinds = ["actions", "dependabot"]
    secrets = {
      RDS_PASSWORD = { value = "hunter2" }
    }
  }

  assert {
    condition     = length(github_dependabot_secret.this) == 1
    error_message = "Expected a dependabot secret when kinds includes dependabot."
  }
}

run "environment_target_creates_environment_secret" {
  command = plan

  variables {
    targets = {
      environments = [{ repository = "api", environment = "prod" }]
    }
    secrets = {
      RDS_PASSWORD = { value = "hunter2" }
    }
  }

  assert {
    condition     = length(github_actions_environment_secret.this) == 1
    error_message = "Expected one environment secret."
  }
}

# Regression: the headline use case is wiring a sensitive producer output
# (an RDS master password, a Key Vault secret) straight into this module.
# for_each must never be derived from var.secrets, or every such call fails
# at plan time with "Sensitive values ... cannot be used as for_each arguments".
run "accepts_a_sensitive_value" {
  command = plan

  variables {
    secrets = {
      RDS_PASSWORD = { value = sensitive("hunter2") }
    }
  }

  assert {
    condition     = length(github_actions_secret.this) == 1
    error_message = "A sensitive secret value must plan successfully."
  }
}

run "accepts_a_sensitive_value_alongside_generation" {
  command = plan

  variables {
    secrets = {
      RDS_PASSWORD  = { value = sensitive("hunter2") }
      SERVICE_TOKEN = { generate = { length = 40, special = false, rotation_days = 90 } }
    }
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Generation must still work when another entry is sensitive."
  }
}
