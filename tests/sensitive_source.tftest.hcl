##-----------------------------------------------------------------------------
## Regression test for sensitive secret maps.
##
## The headline use case is wiring credentials produced elsewhere (an RDS master
## password, a Key Vault secret) into GitHub. Those arrive as sensitive values,
## and a source submodule's `values` output marks the entire map sensitive.
## Terraform rejects a for_each derived from a sensitive value, so every
## resource in the secrets module must iterate key names via nonsensitive().
##-----------------------------------------------------------------------------
mock_provider "github" {}
mock_provider "random" {}
mock_provider "time" {}

mock_provider "azurerm" {
  mock_data "azurerm_key_vault_secret" {
    defaults = {
      value = "kv-secret-value"
    }
  }
}

run "a_sensitive_source_map_can_be_merged_into_secrets" {
  command = plan

  module {
    source = "./tests/fixtures/sensitive_source"
  }

  assert {
    condition     = length(output.secret_names) == 2
    error_message = "Both the pulled and the generated secret must plan successfully."
  }
}
