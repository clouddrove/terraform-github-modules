## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| archive\_on\_destroy | Archive rather than delete the repository on destroy. Deleting a repository is irreversible. | `bool` | `true` | no |
| collaborators | Repository access. Maps of username or team slug to permission (pull, triage, push, maintain, admin). | <pre>object({<br>    users = optional(map(string), {})<br>    teams = optional(map(string), {})<br>  })</pre> | `{}` | no |
| description | Repository description. | `string` | `""` | no |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| environments | Environments to create on the repository, keyed by environment name. | <pre>map(object({<br>    wait_timer = optional(number)<br>    reviewers = optional(object({<br>      users = optional(list(number), [])<br>      teams = optional(list(number), [])<br>    }), {})<br>    deployment_branch_policy = optional(object({<br>      protected_branches     = bool<br>      custom_branch_policies = bool<br>    }))<br>    branch_patterns = optional(list(string), [])<br>  }))</pre> | `{}` | no |
| files | Files to manage in the repository, keyed by path. | <pre>map(object({<br>    content             = string<br>    branch              = optional(string)<br>    commit_message      = optional(string)<br>    commit_author       = optional(string)<br>    commit_email        = optional(string)<br>    overwrite_on_create = optional(bool, false)<br>  }))</pre> | `{}` | no |
| issue\_labels | Issue labels, keyed by label name. | <pre>map(object({<br>    color       = string<br>    description = optional(string)<br>  }))</pre> | `{}` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| ruleset | Ruleset applied to the repository. Null skips ruleset creation. | <pre>object({<br>    ruleset_name = string<br>    target       = optional(string, "branch")<br>    enforcement  = optional(string, "active")<br>    conditions = optional(object({<br>      ref_name = optional(object({<br>        include = optional(list(string), ["~DEFAULT_BRANCH"])<br>        exclude = optional(list(string), [])<br>      }), {})<br>    }), {})<br>    rules = optional(any, {})<br>  })</pre> | `null` | no |
| secret\_kinds | Default secret kinds to publish. One or more of actions, dependabot, codespaces. | `list(string)` | <pre>[<br>  "actions"<br>]</pre> | no |
| secrets | Secrets and variables to publish to GitHub, keyed by secret name.<br>Set exactly one of `value` or `generate` per entry.<br>Set `as_variable = true` to publish a GitHub Actions variable instead of a<br>secret. Variables are not encrypted and are visible in workflow logs. | <pre>map(object({<br>    value = optional(string)<br>    generate = optional(object({<br>      length           = optional(number, 32)<br>      special          = optional(bool, true)<br>      override_special = optional(string)<br>      rotation_days    = optional(number)<br>    }))<br>    as_variable = optional(bool, false)<br>    kinds       = optional(list(string))<br>  }))</pre> | `{}` | no |
| topics | Topics applied to the repository. Topic names must be lowercase. | `list(string)` | `[]` | no |
| visibility | Repository visibility. One of public, private, internal. | `string` | `"private"` | no |
| vulnerability\_alerts | Enable Dependabot vulnerability alerts. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| environment\_names | Environments created on the repository. |
| generated\_values | Generated secret values, keyed by secret name. |
| repository\_full\_name | Full name of the created repository, owner/name. |
| repository\_name | Name of the created repository. |
| repository\_node\_id | GraphQL node ID of the created repository, needed by ruleset bypass actors. |
| ruleset\_id | ID of the repository ruleset, or null when no ruleset was requested. |
| secret\_names | Names of the secrets published to the repository. |
| variable\_names | Names of the GitHub Actions variables published to the repository. |

