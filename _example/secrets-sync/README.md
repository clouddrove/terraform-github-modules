## Terraform state contains these secrets in clear text

The GitHub provider takes secret values as ordinary resource arguments, and
Terraform records every one of those arguments in state. In provider 6.13.0
the argument is `value` on the five Actions and Dependabot secret resources,
where `plaintext_value` and `encrypted_value` are both deprecated, and it is
still `plaintext_value` on the two Codespaces resources. The name of the
argument changes nothing about the exposure: the value lands in the state file
either way. Marking a value sensitive hides it from CLI output; it does not
encrypt or omit it in the state file. Anyone who can read the state file can
read every secret this example publishes.

Before running this example:

- Use a remote backend encrypted with a customer-managed key (S3 with a KMS
  CMK, or an AzureRM backend with a CMK).
- Restrict read access on the state object to the pipeline identity.
- Enable versioning and access logging on the state bucket or container.
- Never commit a `.tfvars` file containing secret values.

For cloud provider access specifically, prefer OIDC federation over stored
credentials. See `modules/actions` for the subject claim customization
templates that make it work.

## What this example does

It draws secret material from three places and publishes all of it through one
call to `modules/secrets`:

| Source | Submodule | Secrets |
| --- | --- | --- |
| AWS Secrets Manager and SSM Parameter Store | `modules/secrets-source-aws` | `STRIPE_KEY`, `DD_API_KEY` |
| Azure Key Vault | `modules/secrets-source-azure` | `AZ_CLIENT_SECRET` |
| Another Terraform module in the same run | none, passed directly | `RDS_PASSWORD`, `DB_HOST` |
| Generated in this run | `modules/secrets` | `SERVICE_TOKEN` |

`DB_HOST` is published as a GitHub Actions variable rather than a secret, so it
is readable in workflow logs. `SERVICE_TOKEN` is generated with a 90 day
rotation window, which means the value changes on the first apply after the
window elapses.

Each secret lands in three scopes: the `api` and `worker` repositories, the
organization with `selected` visibility limited to `api`, and the `prod`
environment on `api`. Dependabot copies are written alongside the Actions
copies because `kinds` asks for both. GitHub has no environment scope for
Dependabot or Codespaces secrets, so those two kinds are written at repository
and organization scope only.

## Wiring a producer module

`var.rds_master_password` and `var.rds_endpoint` stand in for the outputs of
whatever module creates the database. In a real root module you would drop the
variables and write the module reference directly:

```hcl
RDS_PASSWORD = { value = module.rds.master_password }
DB_HOST      = { value = module.rds.endpoint, as_variable = true }
```

That is the point of the split: `modules/secrets` never needs an AWS or Azure
provider, so a caller who only pushes values produced elsewhere configures
nothing but GitHub.

## Usage

```bash
export GITHUB_TOKEN=...
terraform init
terraform plan
terraform apply
```

The AWS and Azure credentials come from the ambient provider configuration.
The `secrets-source-aws` and `secrets-source-azure` submodules read data
sources only; they never create or modify anything in either cloud.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.13.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.9.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.14.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 5.3.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aws_secrets"></a> [aws\_secrets](#module\_aws\_secrets) | ../../modules/secrets-source-aws | n/a |
| <a name="module_azure_secrets"></a> [azure\_secrets](#module\_azure\_secrets) | ../../modules/secrets-source-azure | n/a |
| <a name="module_github_secrets"></a> [github\_secrets](#module\_github\_secrets) | ../../modules/secrets | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_key_vault.prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_rds_endpoint"></a> [rds\_endpoint](#input\_rds\_endpoint) | Endpoint produced by the database module. | `string` | n/a | yes |
| <a name="input_rds_master_password"></a> [rds\_master\_password](#input\_rds\_master\_password) | Master password produced by the database module. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | Names of every secret published by this example. |
| <a name="output_variable_names"></a> [variable\_names](#output\_variable\_names) | Names of every GitHub Actions variable published by this example. |
<!-- END_TF_DOCS -->
