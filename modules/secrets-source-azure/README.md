# modules/secrets-source-azure

Reads secret values from Azure Key Vault and emits them in the shape
[`modules/secrets`](../secrets) accepts, so the two compose with a plain
`merge()`.

This module contains data sources only. It never creates or modifies anything
in Azure. The `azurerm` provider floor is `>= 4.0` and is deliberately not
raised to 5.x: a major floor here would force a provider upgrade on every
consumer for no functional gain.

## Why this is a separate module

Terraform configures a provider whenever the graph contains resource nodes
belonging to it, including nodes gated to zero instances. Folding this data
source into `modules/secrets` behind a `count = 0` flag would therefore still
require every caller to configure and download the azurerm provider, even the
ones pushing a literal string. Keeping Azure in its own submodule is what makes
it genuinely opt-in.

## Usage

```hcl
module "azure_source" {
  source = "clouddrove/github-modules/github//modules/secrets-source-azure"

  secrets = {
    AZ_CLIENT_SECRET = {
      key_vault_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
      name         = "gha-sp"
    }
  }
}

module "github_secrets" {
  source = "clouddrove/github-modules/github//modules/secrets"

  secrets = module.azure_source.values
  targets = { repositories = ["api"] }
}
```

Map keys become GitHub secret names and must match `^[A-Z_][A-Z0-9_]*$`.
`name` is the secret name inside the vault, which has no such restriction.

The `values` output is marked sensitive as a whole map. That is intentional and
`modules/secrets` handles it; see that module's README for why every `for_each`
there iterates key names.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 5.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets to read from Azure Key Vault, keyed by the GitHub secret name they<br/>will become. `name` is the secret name inside the vault. | <pre>map(object({<br/>    key_vault_id = string<br/>    name         = string<br/>    version      = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_values"></a> [values](#output\_values) | Resolved secret values, shaped for the secrets module's `secrets` input. Merge this into that map. |
<!-- END_TF_DOCS -->
