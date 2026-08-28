##-----------------------------------------------------------------------------
## Fixture for the sensitive-map regression test.
##
## Reproduces the composition the spec prescribes: a source submodule emits a
## `values` output declared sensitive, and that whole map is merged into the
## secrets module. The map carries the sensitive mark, not just its elements,
## which is what breaks a for_each derived from var.secrets.
##-----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    github  = { source = "integrations/github" }
    azurerm = { source = "hashicorp/azurerm" }
    random  = { source = "hashicorp/random" }
    time    = { source = "hashicorp/time" }
  }
}

module "azure_source" {
  source = "../../../modules/secrets-source-azure"

  secrets = {
    AZ_CLIENT_SECRET = {
      key_vault_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
      name         = "gha-sp"
    }
  }
}

module "github_secrets" {
  source = "../../../modules/secrets"

  # Merged with a generated entry so the random_password and time_rotating
  # for_each expressions are exercised against a sensitive map too.
  secrets = merge(
    module.azure_source.values,
    {
      SERVICE_TOKEN = { generate = { length = 40, special = false, rotation_days = 90 } }
    }
  )

  targets = { repositories = ["api"] }
}

output "secret_names" {
  description = "Names published by the secrets module in this fixture."
  value       = module.github_secrets.secret_names
}
