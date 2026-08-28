# modules/ruleset

Manages a GitHub ruleset at either repository or organization scope. Rulesets
are the successor to branch protection: one resource covers branch and tag
targets, bypass actors, and the whole rule set.

Set `scope` to `repository` and pass `repository`, or set it to `organization`
and leave `repository` null. Variable validation enforces the pairing, and it
runs even when `enabled` is `false`, so a disabled repository-scoped instance
still needs a placeholder repository name.

## Usage

```hcl
module "ruleset" {
  source = "clouddrove/github-modules/github//modules/ruleset"

  name        = "api"
  environment = "prod"

  scope       = "repository"
  repository  = module.repository.repository_name
  target      = "branch"
  enforcement = "active"

  conditions = {
    ref_name = {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules = {
    deletion         = true
    non_fast_forward = true
    pull_request = {
      required_approving_review_count = 2
    }
  }
}
```

Bypass actors take GraphQL node IDs. `modules/team` exposes `team_node_id` and
`modules/repository` exposes `repository_node_id` for exactly this.

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
| [github_branch_protection.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_organization_ruleset.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_ruleset) | resource |
| [github_repository_ruleset.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_ruleset) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_branch_protection"></a> [branch\_protection](#input\_branch\_protection) | Classic branch protection, for repositories not yet migrated to rulesets. Keyed by an arbitrary label. Defaults are secure-by-default: signed commits required and two approving reviews. Lower them explicitly per entry if a repository cannot meet them. | <pre>map(object({<br/>    pattern                         = string<br/>    enforce_admins                  = optional(bool, true)<br/>    require_signed_commits          = optional(bool, true)<br/>    required_linear_history         = optional(bool, true)<br/>    allows_deletions                = optional(bool, false)<br/>    allows_force_pushes             = optional(bool, false)<br/>    required_approving_review_count = optional(number, 2)<br/>  }))</pre> | `{}` | no |
| <a name="input_bypass_actors"></a> [bypass\_actors](#input\_bypass\_actors) | Actors allowed to bypass the ruleset. actor\_type is one of RepositoryRole, Team, Integration, OrganizationAdmin. | <pre>list(object({<br/>    actor_id    = number<br/>    actor_type  = string<br/>    bypass_mode = optional(string, "always")<br/>  }))</pre> | `[]` | no |
| <a name="input_conditions"></a> [conditions](#input\_conditions) | Ruleset conditions. Use ~DEFAULT\_BRANCH or ~ALL in ref\_name.include. repository\_name applies to organization scope only. | <pre>object({<br/>    ref_name = optional(object({<br/>      include = optional(list(string), [])<br/>      exclude = optional(list(string), [])<br/>    }))<br/>    repository_name = optional(object({<br/>      include   = optional(list(string), [])<br/>      exclude   = optional(list(string), [])<br/>      protected = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_enforcement"></a> [enforcement](#input\_enforcement) | Enforcement level. One of active, evaluate, disabled. | `string` | `"active"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository the ruleset applies to. Required when scope is repository. | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | Rules to enforce. Unset attributes are not enforced. | <pre>object({<br/>    creation                = optional(bool)<br/>    update                  = optional(bool)<br/>    deletion                = optional(bool)<br/>    required_linear_history = optional(bool)<br/>    required_signatures     = optional(bool)<br/>    non_fast_forward        = optional(bool)<br/>    pull_request = optional(object({<br/>      dismiss_stale_reviews_on_push     = optional(bool, true)<br/>      require_code_owner_review         = optional(bool, true)<br/>      require_last_push_approval        = optional(bool, false)<br/>      required_approving_review_count   = optional(number, 1)<br/>      required_review_thread_resolution = optional(bool, true)<br/>    }))<br/>    required_status_checks = optional(object({<br/>      strict_required_status_checks_policy = optional(bool, true)<br/>      required_check = list(object({<br/>        context        = string<br/>        integration_id = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_ruleset_name"></a> [ruleset\_name](#input\_ruleset\_name) | Name of the ruleset. | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Ruleset scope. One of repository, organization. | `string` | `"repository"` | no |
| <a name="input_target"></a> [target](#input\_target) | What the ruleset targets. One of branch, tag, push. | `string` | `"branch"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_ruleset_id"></a> [ruleset\_id](#output\_ruleset\_id) | ID of the created ruleset. |
| <a name="output_ruleset_node_id"></a> [ruleset\_node\_id](#output\_ruleset\_node\_id) | GraphQL node ID of the created ruleset. |
<!-- END_TF_DOCS -->
