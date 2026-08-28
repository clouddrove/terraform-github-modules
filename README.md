# Terraform GitHub Modules

[![Latest Release](https://img.shields.io/github/release/clouddrove/terraform-github-modules.svg)](https://github.com/clouddrove/terraform-github-modules/releases/latest)
[![Licence](https://img.shields.io/badge/License-APACHE-blue.svg)](LICENSE)

Terraform modules to manage GitHub organizations, repositories, rulesets,
teams, environments, Actions configuration, and secrets. Includes a secrets
module that publishes credentials produced by other Terraform modules, such as
an AWS RDS password or an Azure Key Vault secret, into GitHub Actions,
Dependabot, and Codespaces secrets.

## Prerequisites

- [Terraform 1.10.0](https://developer.hashicorp.com/terraform/install) or later
- `integrations/github` provider 6.13.0 or later
- A GitHub token with the scopes the modules you use require

## Modules

| Module | Providers | Purpose |
| --- | --- | --- |
| root (this directory) | github, random, time | Baseline composite: one repository, its ruleset, its environments, and the secrets published to them |
| [`modules/repository`](modules/repository) | github | Repository settings, topics, files, labels, collaborators, deploy keys, branches |
| [`modules/ruleset`](modules/ruleset) | github | Repository or organization rulesets and bypass actors |
| [`modules/team`](modules/team) | github | Teams, authoritative membership, repository grants, review delegation |
| [`modules/organization`](modules/organization) | github | Organization profile, security defaults, membership, custom roles and properties |
| [`modules/environment`](modules/environment) | github | Deployment environments, wait timers, reviewers, branch policies |
| [`modules/actions`](modules/actions) | github | Actions permissions, runner groups, OIDC subject claim customization |
| [`modules/webhook`](modules/webhook) | github | Repository and organization webhooks |
| [`modules/secrets`](modules/secrets) | github, random, time | Secrets and Actions variables at repository, organization, and environment scope |
| [`modules/secrets-source-aws`](modules/secrets-source-aws) | aws | Reads Secrets Manager and SSM Parameter Store values for `modules/secrets` |
| [`modules/secrets-source-azure`](modules/secrets-source-azure) | azurerm | Reads Key Vault values for `modules/secrets` |
| [`wrappers`](wrappers) | github, random, time | Map-driven wrapper around the baseline root, one instance per entry |

The two source submodules exist so that the `aws` and `azurerm` providers stay
opt-in. See [`docs/architecture.md`](docs/architecture.md) for why.

## Documentation

- [`docs/architecture.md`](docs/architecture.md): the single-repo decision, the
  three-way secrets split, and the data flow diagram
- [`docs/io.md`](docs/io.md): every input and output of every submodule, the
  reference to diff when upgrading
- [`CHANGELOG.md`](CHANGELOG.md): release history

## Usage

```hcl
module "github" {
  source  = "clouddrove/github-modules/github"
  version = "0.0.1"

  name        = "api"
  environment = "prod"
  description = "API service"
  visibility  = "private"
  topics      = ["terraform", "api"]

  ruleset = {
    ruleset_name = "main-protection"
    rules = {
      deletion         = true
      non_fast_forward = true
      pull_request = {
        required_approving_review_count = 2
      }
    }
  }
}
```

Each submodule is independently consumable:

```hcl
module "secrets" {
  source = "clouddrove/github-modules/github//modules/secrets"
  # ...
}
```

## Examples

| Example | What it shows |
| --- | --- |
| [`_example/basic`](_example/basic) | One private repository and a branch ruleset |
| [`_example/complete`](_example/complete) | Every submodule wired into one configuration |
| [`_example/secrets-sync`](_example/secrets-sync) | AWS, Azure, and producer-module credentials published through one secrets call |
| [`_example/terragrunt`](_example/terragrunt) | The baseline root driven by Terragrunt |

## Secret values are stored in Terraform state

Any module here that accepts a secret, `modules/secrets` and the `secret`
argument of `modules/webhook`, writes that value into Terraform state in clear
text. Read
[the warning in `modules/secrets`](modules/secrets#terraform-state-contains-these-secrets-in-clear-text)
before using either. For cloud provider access prefer OIDC federation, which
`modules/actions` configures, over any stored credential.

## Development

```bash
make fmt        # terraform fmt -recursive
make validate   # validate the root and every submodule
make test       # terraform test at the root and in every submodule
make ci         # fmt, validate, test
make docs       # regenerate the terraform-docs tables in every README
make tflint     # tflint across the tree
make security   # gitleaks and checkov
```

`README.md` files are partly generated. The prose above the
`BEGIN_TF_DOCS` marker is hand-written and preserved; everything between the
markers comes from `make docs` and must never be hand-edited.

## License

Apache 2.0. See [LICENSE](LICENSE).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.13.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.9.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.14.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_environments"></a> [environments](#module\_environments) | ./modules/environment | n/a |
| <a name="module_repository"></a> [repository](#module\_repository) | ./modules/repository | n/a |
| <a name="module_ruleset"></a> [ruleset](#module\_ruleset) | ./modules/ruleset | n/a |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ./modules/secrets | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_archive_on_destroy"></a> [archive\_on\_destroy](#input\_archive\_on\_destroy) | Archive rather than delete the repository on destroy. Deleting a repository is irreversible. | `bool` | `true` | no |
| <a name="input_collaborators"></a> [collaborators](#input\_collaborators) | Repository access. Maps of username or team slug to permission (pull, triage, push, maintain, admin). | <pre>object({<br/>    users = optional(map(string), {})<br/>    teams = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Repository description. | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Environments to create on the repository, keyed by environment name. | <pre>map(object({<br/>    wait_timer = optional(number)<br/>    reviewers = optional(object({<br/>      users = optional(list(number), [])<br/>      teams = optional(list(number), [])<br/>    }), {})<br/>    deployment_branch_policy = optional(object({<br/>      protected_branches     = bool<br/>      custom_branch_policies = bool<br/>    }))<br/>    branch_patterns = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_files"></a> [files](#input\_files) | Files to manage in the repository, keyed by path. | <pre>map(object({<br/>    content             = string<br/>    branch              = optional(string)<br/>    commit_message      = optional(string)<br/>    commit_author       = optional(string)<br/>    commit_email        = optional(string)<br/>    overwrite_on_create = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_issue_labels"></a> [issue\_labels](#input\_issue\_labels) | Issue labels, keyed by label name. | <pre>map(object({<br/>    color       = string<br/>    description = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_ruleset"></a> [ruleset](#input\_ruleset) | Ruleset applied to the repository. Null skips ruleset creation. | <pre>object({<br/>    ruleset_name = string<br/>    target       = optional(string, "branch")<br/>    enforcement  = optional(string, "active")<br/>    conditions = optional(object({<br/>      ref_name = optional(object({<br/>        include = optional(list(string), ["~DEFAULT_BRANCH"])<br/>        exclude = optional(list(string), [])<br/>      }), {})<br/>    }), {})<br/>    rules = optional(any, {})<br/>  })</pre> | `null` | no |
| <a name="input_secret_kinds"></a> [secret\_kinds](#input\_secret\_kinds) | Default secret kinds to publish. One or more of actions, dependabot, codespaces. | `list(string)` | <pre>[<br/>  "actions"<br/>]</pre> | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets and variables to publish to GitHub, keyed by secret name.<br/>Set exactly one of `value` or `generate` per entry.<br/>Set `as_variable = true` to publish a GitHub Actions variable instead of a<br/>secret. Variables are not encrypted and are visible in workflow logs. | <pre>map(object({<br/>    value = optional(string)<br/>    generate = optional(object({<br/>      length           = optional(number, 32)<br/>      special          = optional(bool, true)<br/>      override_special = optional(string)<br/>      rotation_days    = optional(number)<br/>    }))<br/>    as_variable = optional(bool, false)<br/>    kinds       = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Topics applied to the repository. Topic names must be lowercase. | `list(string)` | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Repository visibility. One of public, private, internal. | `string` | `"private"` | no |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability\_alerts) | Enable Dependabot vulnerability alerts. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_environment_names"></a> [environment\_names](#output\_environment\_names) | Environments created on the repository. |
| <a name="output_generated_values"></a> [generated\_values](#output\_generated\_values) | Generated secret values, keyed by secret name. |
| <a name="output_repository_full_name"></a> [repository\_full\_name](#output\_repository\_full\_name) | Full name of the created repository, owner/name. |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the created repository. |
| <a name="output_repository_node_id"></a> [repository\_node\_id](#output\_repository\_node\_id) | GraphQL node ID of the created repository, needed by ruleset bypass actors. |
| <a name="output_ruleset_id"></a> [ruleset\_id](#output\_ruleset\_id) | ID of the repository ruleset, or null when no ruleset was requested. |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | Names of the secrets published to the repository. |
| <a name="output_variable_names"></a> [variable\_names](#output\_variable\_names) | Names of the GitHub Actions variables published to the repository. |
<!-- END_TF_DOCS -->
