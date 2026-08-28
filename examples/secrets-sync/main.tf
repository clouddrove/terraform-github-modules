data "azurerm_key_vault" "prod" {
  name                = "prod-key-vault"
  resource_group_name = "prod-rg"
}

module "aws_secrets" {
  source = "../../modules/secrets-source-aws"

  secrets = {
    STRIPE_KEY = { arn = "arn:aws:secretsmanager:eu-west-1:1234:secret:app/stripe", json_key = "api_key" }
    DD_API_KEY = { ssm_parameter = "/prod/datadog/api_key" }
  }
}

module "azure_secrets" {
  source = "../../modules/secrets-source-azure"

  secrets = {
    AZ_CLIENT_SECRET = { key_vault_id = data.azurerm_key_vault.prod.id, name = "gha-sp" }
  }
}

module "github_secrets" {
  source = "../../modules/secrets"

  name        = "api"
  environment = "prod"

  secrets = merge(
    module.aws_secrets.values,
    module.azure_secrets.values,
    {
      RDS_PASSWORD  = { value = var.rds_master_password }
      DB_HOST       = { value = var.rds_endpoint, as_variable = true }
      SERVICE_TOKEN = { generate = { length = 40, special = false, rotation_days = 90 } }
    }
  )

  kinds = ["actions", "dependabot"]

  targets = {
    repositories = ["api", "worker"]
    organization = { visibility = "selected", selected_repositories = ["api"] }
    environments = [{ repository = "api", environment = "prod" }]
  }
}
