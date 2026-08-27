mock_provider "aws" {
  mock_data "aws_secretsmanager_secret_version" {
    defaults = {
      secret_string = "{\"api_key\":\"sk_live_abc\",\"other\":\"ignored\"}"
    }
  }

  mock_data "aws_ssm_parameter" {
    defaults = {
      value = "ssm-plain-value"
    }
  }
}

run "reads_a_plain_secretsmanager_secret" {
  command = plan

  variables {
    secrets = {
      STRIPE_KEY = { arn = "arn:aws:secretsmanager:eu-west-1:1234:secret:app/stripe" }
    }
  }

  assert {
    condition     = length(output.values) == 1
    error_message = "Expected one resolved value."
  }
}

run "reads_an_ssm_parameter" {
  command = plan

  variables {
    secrets = {
      DD_API_KEY = { ssm_parameter = "/prod/datadog/api_key" }
    }
  }

  assert {
    condition     = length(output.values) == 1
    error_message = "Expected one resolved value."
  }
}

run "rejects_both_arn_and_ssm_parameter" {
  command = plan

  variables {
    secrets = {
      BAD = { arn = "arn:aws:secretsmanager:eu-west-1:1234:secret:x", ssm_parameter = "/x" }
    }
  }

  expect_failures = [var.secrets]
}

run "rejects_neither_arn_nor_ssm_parameter" {
  command = plan

  variables {
    secrets = {
      BAD = {}
    }
  }

  expect_failures = [var.secrets]
}

run "rejects_json_key_on_an_ssm_parameter" {
  command = plan

  variables {
    secrets = {
      BAD = { ssm_parameter = "/x", json_key = "field" }
    }
  }

  expect_failures = [var.secrets]
}

run "enabled_false_reads_nothing" {
  command = plan

  variables {
    enabled = false
    secrets = {
      STRIPE_KEY = { arn = "arn:aws:secretsmanager:eu-west-1:1234:secret:app/stripe" }
    }
  }

  assert {
    condition     = length(output.values) == 0
    error_message = "enabled = false must resolve no values."
  }
}
