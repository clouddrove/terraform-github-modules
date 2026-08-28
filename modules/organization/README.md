# modules/organization

Manages organization level GitHub configuration: the organization profile and
security defaults for new repositories, membership, blocked users, custom
repository roles, custom properties, and organization webhook and Actions
adjacent settings that belong to the org rather than to a repository.

A token with organization owner scope is required. This module changes
settings that apply to every repository in the organization, so review a plan
carefully before applying it.

Membership is authoritative for the usernames listed in `members`. Users not
listed are left alone; users listed with a changed role are updated.

Custom roles use `github_organization_repository_role`, which replaces the
older custom role resource in provider 6.13.0.

## Usage

```hcl
module "organization" {
  source = "clouddrove/github-modules/github//modules/organization"

  name        = "clouddrove"
  environment = "prod"

  billing_email                 = "billing@clouddrove.com"
  default_repository_permission = "read"

  dependabot_alerts_enabled_for_new_repositories = true
  secret_scanning_enabled_for_new_repositories   = true

  members = {
    alice = "admin"
    bob   = "member"
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
| [github_membership.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/membership) | resource |
| [github_organization_block.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_block) | resource |
| [github_organization_custom_properties.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_custom_properties) | resource |
| [github_organization_repository_role.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_repository_role) | resource |
| [github_organization_settings.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_settings) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_advanced_security_enabled_for_new_repositories"></a> [advanced\_security\_enabled\_for\_new\_repositories](#input\_advanced\_security\_enabled\_for\_new\_repositories) | Enable GitHub Advanced Security on new repositories. Requires a GHAS licence. | `bool` | `false` | no |
| <a name="input_billing_email"></a> [billing\_email](#input\_billing\_email) | Billing email for the organization. Required when manage\_settings is true. | `string` | `null` | no |
| <a name="input_blocked_users"></a> [blocked\_users](#input\_blocked\_users) | Usernames blocked from the organization. | `list(string)` | `[]` | no |
| <a name="input_blog"></a> [blog](#input\_blog) | Organization website URL. | `string` | `null` | no |
| <a name="input_company"></a> [company](#input\_company) | Company name shown on the organization profile. | `string` | `null` | no |
| <a name="input_custom_properties"></a> [custom\_properties](#input\_custom\_properties) | Organization custom properties, keyed by property name. | <pre>map(object({<br/>    value_type         = string<br/>    required           = optional(bool, false)<br/>    default_value      = optional(string)<br/>    description        = optional(string)<br/>    allowed_values     = optional(list(string))<br/>    values_editable_by = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_roles"></a> [custom\_roles](#input\_custom\_roles) | Custom organization repository roles, keyed by role name. | <pre>map(object({<br/>    description = string<br/>    base_role   = string<br/>    permissions = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_default_repository_permission"></a> [default\_repository\_permission](#input\_default\_repository\_permission) | Base permission members get on all repositories. One of none, read, write, admin. | `string` | `"read"` | no |
| <a name="input_dependabot_alerts_enabled_for_new_repositories"></a> [dependabot\_alerts\_enabled\_for\_new\_repositories](#input\_dependabot\_alerts\_enabled\_for\_new\_repositories) | Enable Dependabot alerts on new repositories. | `bool` | `true` | no |
| <a name="input_email"></a> [email](#input\_email) | Public email address for the organization. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Organization location. | `string` | `null` | no |
| <a name="input_manage_settings"></a> [manage\_settings](#input\_manage\_settings) | Whether to manage organization-wide settings. Set false to manage only membership and blocks. | `bool` | `true` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_members"></a> [members](#input\_members) | Organization membership, mapping username to role. One of member, admin. | `map(string)` | `{}` | no |
| <a name="input_members_can_create_public_repositories"></a> [members\_can\_create\_public\_repositories](#input\_members\_can\_create\_public\_repositories) | Allow members to create public repositories. | `bool` | `false` | no |
| <a name="input_members_can_create_repositories"></a> [members\_can\_create\_repositories](#input\_members\_can\_create\_repositories) | Allow members to create repositories. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_organization_description"></a> [organization\_description](#input\_organization\_description) | Organization description. | `string` | `null` | no |
| <a name="input_secret_scanning_enabled_for_new_repositories"></a> [secret\_scanning\_enabled\_for\_new\_repositories](#input\_secret\_scanning\_enabled\_for\_new\_repositories) | Enable secret scanning on new repositories. | `bool` | `true` | no |
| <a name="input_secret_scanning_push_protection_enabled_for_new_repositories"></a> [secret\_scanning\_push\_protection\_enabled\_for\_new\_repositories](#input\_secret\_scanning\_push\_protection\_enabled\_for\_new\_repositories) | Enable secret scanning push protection on new repositories. | `bool` | `true` | no |
| <a name="input_web_commit_signoff_required"></a> [web\_commit\_signoff\_required](#input\_web\_commit\_signoff\_required) | Require contributors to sign off on web-based commits. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_member_usernames"></a> [member\_usernames](#output\_member\_usernames) | Usernames whose membership this module manages. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | ID of the managed organization settings resource. |
<!-- END_TF_DOCS -->
