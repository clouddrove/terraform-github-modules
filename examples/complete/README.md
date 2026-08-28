# Complete example

Every submodule in this repository, wired into one configuration.

| Module | What it does here |
| --- | --- |
| `modules/organization` | Organization profile, base member permission, security defaults for new repositories, one custom property |
| `modules/team` | The `platform-prod` team, its membership, its grant on the repository, and round robin review delegation |
| `modules/secrets-source-aws` | Reads `STRIPE_KEY` from Secrets Manager and `DD_API_KEY` from SSM Parameter Store |
| `modules/secrets-source-azure` | Reads `AZ_CLIENT_SECRET` from Key Vault |
| root (`modules/repository`, `modules/ruleset`, `modules/environment`, `modules/secrets`) | The repository, its branch ruleset, a `staging` and a `prod` environment, and every secret above |
| `modules/webhook` | Deployment webhook on the repository |
| `modules/actions` | Actions permissions, a private self-hosted runner group, and OIDC subject claim templates |

## Notes on the wiring

The repository, ruleset, environments, and secrets come from one call to the
baseline composite root rather than four separate submodule calls. The root
already sequences them: the ruleset and the environments take the repository
name from the repository submodule, and the secrets submodule takes both the
repository and the environment targets. Calling the four submodules directly
works too, and is what you want when a repository already exists and only its
ruleset is managed here.

`modules/actions` sets `repository_oidc_claim_keys`, which is the alternative
to storing cloud credentials as GitHub secrets. Prefer it. The two source
submodules exist for credentials that genuinely cannot be federated, such as a
third party API key held in Secrets Manager.

The `staging` environment uses `custom_branch_policies` so it can accept
`release/*` branches. The `prod` environment uses `protected_branches` and a 15
minute wait timer. The two flags are mutually exclusive and the environment
submodule enforces that.

## Read this before you apply

Secret values published through this example are written to Terraform state in
clear text. See `examples/secrets-sync/README.md` for what that means and what
to do about it.

## Usage

```bash
export GITHUB_TOKEN=...
terraform init
terraform plan
terraform apply
```

The token needs organization owner scope, because this example manages
organization settings, membership, and Actions policy. AWS and Azure
credentials come from the ambient provider configuration and are used for read
only data sources.

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
| <a name="module_actions"></a> [actions](#module\_actions) | ../../modules/actions | n/a |
| <a name="module_aws_secrets"></a> [aws\_secrets](#module\_aws\_secrets) | ../../modules/secrets-source-aws | n/a |
| <a name="module_azure_secrets"></a> [azure\_secrets](#module\_azure\_secrets) | ../../modules/secrets-source-azure | n/a |
| <a name="module_baseline"></a> [baseline](#module\_baseline) | ../../ | n/a |
| <a name="module_organization"></a> [organization](#module\_organization) | ../../modules/organization | n/a |
| <a name="module_team"></a> [team](#module\_team) | ../../modules/team | n/a |
| <a name="module_webhook"></a> [webhook](#module\_webhook) | ../../modules/webhook | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_key_vault.prod](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_environment_names"></a> [environment\_names](#output\_environment\_names) | Environments created on the repository. |
| <a name="output_repository_full_name"></a> [repository\_full\_name](#output\_repository\_full\_name) | Full name of the repository, owner/name. |
| <a name="output_runner_group_ids"></a> [runner\_group\_ids](#output\_runner\_group\_ids) | IDs of the self-hosted runner groups, keyed by group name. |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | Names of every secret published to the repository. |
| <a name="output_team_slug"></a> [team\_slug](#output\_team\_slug) | Slug of the owning team. |
| <a name="output_webhook_ids"></a> [webhook\_ids](#output\_webhook\_ids) | IDs of the repository webhooks, keyed by label. |
<!-- END_TF_DOCS -->
