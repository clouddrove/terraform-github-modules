# modules/environment

Creates one deployment environment on a repository, with an optional wait
timer, required reviewers, and a deployment branch policy.

`protected_branches` and `custom_branch_policies` are mutually exclusive in the
GitHub API. Variable validation enforces that, and `branch_patterns` is
accepted only alongside `custom_branch_policies`.

## Feeding the secrets module

The `secrets_target` output emits exactly the object shape that
[`modules/secrets`](../secrets) expects in its `targets.environments` list, so
a set of environments can be wired in without reshaping:

```hcl
targets = {
  environments = [for k, m in module.environments : m.secrets_target]
}
```

## Usage

```hcl
module "environment" {
  source = "clouddrove/github-modules/github//modules/environment"

  name        = "api"
  environment = "prod"

  repository       = module.repository.repository_name
  environment_name = "prod"
  wait_timer       = 15

  # Numeric user and team IDs, not logins or slugs.
  reviewers = {
    users = [1234567]
    teams = [7654321]
  }

  deployment_branch_policy = {
    protected_branches     = true
    custom_branch_policies = false
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.13.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | 6.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_repository_environment.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |
| [github_repository_environment_deployment_policy.tag](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment_deployment_policy) | resource |
| [github_repository_environment_deployment_policy.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment_deployment_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_branch_patterns"></a> [branch\_patterns](#input\_branch\_patterns) | Branch name patterns allowed to deploy. Requires deployment\_branch\_policy.custom\_branch\_policies = true. | `list(string)` | `[]` | no |
| <a name="input_can_admins_bypass"></a> [can\_admins\_bypass](#input\_can\_admins\_bypass) | Allow administrators to bypass the environment protection rules. | `bool` | `false` | no |
| <a name="input_deployment_branch_policy"></a> [deployment\_branch\_policy](#input\_deployment\_branch\_policy) | Which branches may deploy. Exactly one of the two flags must be true. | <pre>object({<br/>    protected_branches     = bool<br/>    custom_branch_policies = bool<br/>  })</pre> | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name, for example prod or staging. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_prevent_self_review"></a> [prevent\_self\_review](#input\_prevent\_self\_review) | Prevent the deployment actor from approving their own deployment. | `bool` | `true` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository the environment belongs to. | `string` | `null` | no |
| <a name="input_reviewers"></a> [reviewers](#input\_reviewers) | Required deployment reviewers, as numeric user and team IDs. | <pre>object({<br/>    users = optional(list(number), [])<br/>    teams = optional(list(number), [])<br/>  })</pre> | `{}` | no |
| <a name="input_tag_patterns"></a> [tag\_patterns](#input\_tag\_patterns) | Tag name patterns allowed to deploy. Requires deployment\_branch\_policy.custom\_branch\_policies = true. | `list(string)` | `[]` | no |
| <a name="input_wait_timer"></a> [wait\_timer](#input\_wait\_timer) | Minutes to delay a deployment. GitHub allows 0 to 43200. | `number` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_environment_name"></a> [environment\_name](#output\_environment\_name) | Name of the environment. |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_repository"></a> [repository](#output\_repository) | Repository the environment belongs to. |
| <a name="output_secrets_target"></a> [secrets\_target](#output\_secrets\_target) | Value to append to the secrets module's targets.environments list. |
<!-- END_TF_DOCS -->
