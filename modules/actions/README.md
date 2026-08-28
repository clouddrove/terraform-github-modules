# modules/actions

GitHub Actions administration: organization and repository Actions permissions,
self-hosted runner groups, private repository workflow access level, and OIDC
subject claim customization templates.

## Prefer OIDC over stored cloud credentials

For cloud access specifically, OIDC subject claim customization is the stronger
option. A workflow exchanges a short lived GitHub OIDC token for AWS or Azure
credentials at run time, so no long lived access key ever exists as a GitHub
secret to leak, rotate, or audit.

Set `repository_oidc_claim_keys` (or `organization_oidc_claim_keys`) to shape
the `sub` claim your cloud trust policy matches on, for example
`["repo", "context", "job_workflow_ref"]`. Then scope the AWS IAM role trust
policy or the Azure federated identity credential to that subject.

Use [`modules/secrets`](../secrets) for the values OIDC cannot cover: third
party API tokens, registry passwords, and anything that is not an AWS or Azure
credential. Reach for it for cloud access only when OIDC federation is not
available in your setup.

## Usage

```hcl
module "actions" {
  source = "clouddrove/github-modules/github//modules/actions"

  name        = "api"
  environment = "prod"
  repository  = "api"

  repository_oidc_claim_keys = ["repo", "context", "job_workflow_ref"]

  runner_groups = {
    "self-hosted-prod" = {
      visibility              = "selected"
      selected_repository_ids = [1, 2]
    }
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
| [github_actions_organization_oidc_subject_claim_customization_template.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_oidc_subject_claim_customization_template) | resource |
| [github_actions_organization_permissions.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_organization_permissions) | resource |
| [github_actions_repository_access_level.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_repository_access_level) | resource |
| [github_actions_repository_oidc_subject_claim_customization_template.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_repository_oidc_subject_claim_customization_template) | resource |
| [github_actions_repository_permissions.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_repository_permissions) | resource |
| [github_actions_runner_group.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_runner_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_organization_oidc_claim_keys"></a> [organization\_oidc\_claim\_keys](#input\_organization\_oidc\_claim\_keys) | Organization-wide OIDC subject claim keys. Empty leaves the GitHub default. | `list(string)` | `[]` | no |
| <a name="input_organization_permissions"></a> [organization\_permissions](#input\_organization\_permissions) | Organization-wide Actions permissions. | <pre>object({<br/>    allowed_actions      = optional(string, "selected")<br/>    enabled_repositories = optional(string, "all")<br/>    allowed_actions_config = optional(object({<br/>      github_owned_allowed = optional(bool, true)<br/>      verified_allowed     = optional(bool, false)<br/>      patterns_allowed     = optional(list(string), [])<br/>    }))<br/>    enabled_repository_ids = optional(list(number), [])<br/>  })</pre> | `null` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository for repository-scoped settings. Null means organization scope only. | `string` | `null` | no |
| <a name="input_repository_access_level"></a> [repository\_access\_level](#input\_repository\_access\_level) | Access level for a private repository's Actions workflows. One of none, user, organization. | `string` | `null` | no |
| <a name="input_repository_oidc_claim_keys"></a> [repository\_oidc\_claim\_keys](#input\_repository\_oidc\_claim\_keys) | Repository OIDC subject claim keys, for example ["repo", "context"]. Requires repository. Prefer OIDC federation over stored cloud credentials. | `list(string)` | `[]` | no |
| <a name="input_repository_permissions"></a> [repository\_permissions](#input\_repository\_permissions) | Repository-scoped Actions permissions. Requires repository. | <pre>object({<br/>    allowed_actions = optional(string, "selected")<br/>    enabled         = optional(bool, true)<br/>    allowed_actions_config = optional(object({<br/>      github_owned_allowed = optional(bool, true)<br/>      verified_allowed     = optional(bool, false)<br/>      patterns_allowed     = optional(list(string), [])<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_runner_groups"></a> [runner\_groups](#input\_runner\_groups) | Self-hosted runner groups, keyed by group name. | <pre>map(object({<br/>    visibility                 = optional(string, "selected")<br/>    selected_repository_ids    = optional(list(number), [])<br/>    allows_public_repositories = optional(bool, false)<br/>    restricted_to_workflows    = optional(bool, false)<br/>    selected_workflows         = optional(list(string), [])<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_runner_group_ids"></a> [runner\_group\_ids](#output\_runner\_group\_ids) | IDs of the created runner groups, keyed by group name. |
<!-- END_TF_DOCS -->
