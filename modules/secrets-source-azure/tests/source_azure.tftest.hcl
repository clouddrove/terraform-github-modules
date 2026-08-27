mock_provider "azurerm" {
  mock_data "azurerm_key_vault_secret" {
    defaults = {
      value = "kv-secret-value"
    }
  }
}

run "reads_a_key_vault_secret" {
  command = plan

  variables {
    secrets = {
      AZ_CLIENT_SECRET = {
        key_vault_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
        name         = "gha-sp"
      }
    }
  }

  assert {
    condition     = length(nonsensitive(output.values)) == 1
    error_message = "Expected one resolved value."
  }
}

run "rejects_a_lowercase_key" {
  command = plan

  variables {
    secrets = {
      az_client_secret = {
        key_vault_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
        name         = "gha-sp"
      }
    }
  }

  expect_failures = [var.secrets]
}

run "enabled_false_reads_nothing" {
  command = plan

  variables {
    enabled = false
    secrets = {
      AZ_CLIENT_SECRET = {
        key_vault_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
        name         = "gha-sp"
      }
    }
  }

  assert {
    condition     = length(nonsensitive(output.values)) == 0
    error_message = "enabled = false must resolve no values."
  }
}
