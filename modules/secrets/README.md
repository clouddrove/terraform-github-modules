# modules/secrets

Publishes secrets and GitHub Actions variables into GitHub at repository,
organization, and environment scope, across the `actions`, `dependabot`, and
`codespaces` kinds. Values are either passed in literally, typically an output
of another Terraform module, or generated inside the module with an optional
rotation window.

## Terraform state contains these secrets in clear text

The GitHub provider takes secret values as ordinary resource arguments, and
Terraform records every one of those arguments in state. In provider 6.13.0
the argument is `value` on the five Actions and Dependabot secret resources,
where `plaintext_value` and `encrypted_value` are both deprecated, and it is
still `plaintext_value` on the two Codespaces resources. The name of the
argument changes nothing about the exposure: the value lands in the state file
either way. Marking a value sensitive hides it from CLI output; it does not
encrypt or omit it in the state file. Anyone who can read the state file can
read every secret this module publishes.

Before using this module:

- Use a remote backend encrypted with a customer-managed key (S3 with a KMS
  CMK, or an AzureRM backend with a CMK).
- Restrict read access on the state object to the pipeline identity.
- Enable versioning and access logging on the state bucket or container.
- Never commit a `.tfvars` file containing secret values.

For cloud provider access specifically, prefer OIDC federation over stored
credentials. See [`modules/actions`](../actions) for the subject claim
customization templates that make it work. A workflow exchanges a short lived
GitHub OIDC token for AWS or Azure credentials at run time, so no long lived
key ever exists as a GitHub secret to leak, rotate, or audit. Reach for this
module for the values OIDC cannot cover: third party API tokens, registry
passwords, and anything that is not an AWS or Azure credential.

## Sensitive maps and `for_each`

Callers merge sensitive maps into `secrets`: the `values` output of
[`modules/secrets-source-aws`](../secrets-source-aws) and
[`modules/secrets-source-azure`](../secrets-source-azure) is marked sensitive
as a whole, and so is an RDS master password read from another module.
Terraform rejects a `for_each` derived from a sensitive value, so every
resource here iterates secret *names* through `nonsensitive()` and looks the
value up inside the resource body. Do not rewrite any `for_each` to iterate
`var.secrets` directly; `tests/sensitive_source.tftest.hcl` at the repository
root is the regression test for this.

## Scope coverage

| Kind | Repository | Organization | Environment |
| --- | :---: | :---: | :---: |
| `actions` | yes | yes | yes |
| `dependabot` | yes | yes | no |
| `codespaces` | yes | yes | no |
| Actions variables | yes | yes | yes |

GitHub has no environment scope for Dependabot or Codespaces secrets, so those
kinds are written at repository and organization scope only.

## Usage

```hcl
module "secrets" {
  source = "clouddrove/github-modules/github//modules/secrets"

  name        = "api"
  environment = "prod"

  kinds = ["actions", "dependabot"]

  secrets = {
    RDS_PASSWORD  = { value = module.rds.master_password }
    DB_HOST       = { value = module.rds.endpoint, as_variable = true }
    SERVICE_TOKEN = { generate = { length = 40, special = false, rotation_days = 90 } }
  }

  targets = {
    repositories = ["api"]
    environments = [{ repository = "api", environment = "prod" }]
  }
}
```

`as_variable = true` publishes a GitHub Actions variable instead of a secret.
Variables are not encrypted by GitHub and are readable in workflow logs, so
they are rejected in combination with `generate`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.13.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.9.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.14.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | 6.13.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.14.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_actions_environment_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_secret) | resource |
| [github_actions_environment_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_actions_organization_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_secret) | resource |
| [github_actions_organization_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_variable) | resource |
| [github_actions_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_variable.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_codespaces_organization_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/codespaces_organization_secret) | resource |
| [github_codespaces_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/codespaces_secret) | resource |
| [github_dependabot_organization_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_organization_secret) | resource |
| [github_dependabot_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/dependabot_secret) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_rotating.this](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [github_repository.selected](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_kinds"></a> [kinds](#input\_kinds) | Default secret kinds to publish. One or more of actions, dependabot, codespaces. | `list(string)` | <pre>[<br/>  "actions"<br/>]</pre> | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets and variables to publish to GitHub, keyed by secret name.<br/>Set exactly one of `value` or `generate` per entry.<br/>Set `as_variable = true` to publish a GitHub Actions variable instead of a<br/>secret. Variables are not encrypted and are visible in workflow logs. | <pre>map(object({<br/>    value = optional(string)<br/>    generate = optional(object({<br/>      length           = optional(number, 32)<br/>      special          = optional(bool, true)<br/>      override_special = optional(string)<br/>      rotation_days    = optional(number)<br/>    }))<br/>    as_variable = optional(bool, false)<br/>    kinds       = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | Where to publish. Provide at least one target when secrets is non-empty. | <pre>object({<br/>    repositories = optional(list(string), [])<br/>    organization = optional(object({<br/>      visibility            = optional(string, "private")<br/>      selected_repositories = optional(list(string), [])<br/>    }))<br/>    environments = optional(list(object({<br/>      repository  = string<br/>      environment = string<br/>    })), [])<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_generated_values"></a> [generated\_values](#output\_generated\_values) | Generated secret values, keyed by secret name. Feed these to the resource that must accept the credential. |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | Names of all secrets published by this module. |
| <a name="output_variable_names"></a> [variable\_names](#output\_variable\_names) | Names of all GitHub Actions variables published by this module. |
<!-- END_TF_DOCS -->
