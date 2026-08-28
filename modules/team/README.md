# modules/team

Creates a GitHub team, its authoritative membership, its repository grants,
automatic review request delegation, and optional IdP group mapping.

## Provider 6.13.0 notes

- Membership uses `github_team_members` with `team_slug`. The `team_id`
  argument on that resource is deprecated.
- `notify` is set at the top level of `github_team_settings`, not inside the
  `review_request_delegation` block, where it is deprecated.
- `create_default_maintainer` is deprecated on `github_team` but is still set
  deliberately. Omitting it risks GitHub adding the team creator as a
  maintainer behind Terraform's back, which shows up as silent membership
  drift. A deprecation warning at plan time is the cheaper of the two.

Membership is authoritative. Anyone added to the team through the GitHub UI is
removed on the next apply.

## Usage

```hcl
module "team" {
  source = "clouddrove/github-modules/github//modules/team"

  name        = "platform"
  environment = "prod"

  description = "Platform engineering"
  privacy     = "closed"

  members = {
    alice = "maintainer"
    bob   = "member"
  }

  repositories = {
    api = "push"
  }

  review_request_delegation = {
    algorithm    = "ROUND_ROBIN"
    member_count = 1
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
| [github_team.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team) | resource |
| [github_team_members.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_members) | resource |
| [github_team_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [github_team_settings.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_settings) | resource |
| [github_team_sync_group_mapping.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_sync_group_mapping) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_create_default_maintainer"></a> [create\_default\_maintainer](#input\_create\_default\_maintainer) | Whether the creating user becomes a maintainer. Leave false so membership is fully declarative. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Team description. | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_members"></a> [members](#input\_members) | Team members, mapping username to role. Role is one of member, maintainer. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_parent_team_id"></a> [parent\_team\_id](#input\_parent\_team\_id) | Parent team ID or slug, for nested teams. | `string` | `null` | no |
| <a name="input_privacy"></a> [privacy](#input\_privacy) | Team privacy. One of secret, closed. Nested teams require closed. | `string` | `"closed"` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Repository grants, mapping repository name to permission. One of pull, triage, push, maintain, admin. | `map(string)` | `{}` | no |
| <a name="input_review_request_delegation"></a> [review\_request\_delegation](#input\_review\_request\_delegation) | Automatic review request delegation settings. | <pre>object({<br/>    algorithm    = optional(string, "ROUND_ROBIN")<br/>    member_count = optional(number, 1)<br/>    notify       = optional(bool, true)<br/>  })</pre> | `null` | no |
| <a name="input_sync_group_mapping"></a> [sync\_group\_mapping](#input\_sync\_group\_mapping) | IdP groups to map to this team. Requires SAML or SCIM on the organization. | <pre>list(object({<br/>    group_id          = string<br/>    group_name        = string<br/>    group_description = optional(string, "")<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | Numeric ID of the team. |
| <a name="output_team_node_id"></a> [team\_node\_id](#output\_team\_node\_id) | GraphQL node ID of the team, used as a ruleset bypass actor. |
| <a name="output_team_slug"></a> [team\_slug](#output\_team\_slug) | URL slug of the team, used in repository grants and CODEOWNERS. |
<!-- END_TF_DOCS -->
