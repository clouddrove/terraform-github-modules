# Module reference

Every input and output of all ten submodules and the baseline composite, with
type and default. Regenerate with `make docs`.

`docs/io.md` is a different file: the CloudDrove readme action generates it from
the root module only and overwrites it on every run, so the whole-suite reference
lives here instead.

`README.md` in each module directory carries the same tables alongside the
prose for that module. This page exists so the whole surface can be read, and
diffed, in one place.

## Standard variables

Every module below accepts the same five variables. They are repeated in each
table for completeness.

| Name | Description | Type | Default |
| ---- | ----------- | ---- | ------- |
| enabled | Flag to control the resources creation. | `bool` | `true` |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | `["name", "environment"]` |

`name` and `environment` are joined in `label_order` sequence to compose the
resource name, so `api` plus `prod` becomes `api-prod`.

## Contents

- [Baseline composite root](#baseline-composite-root)
- [wrappers](#wrappers)
- [modules/repository](#modulesrepository)
- [modules/ruleset](#modulesruleset)
- [modules/team](#modulesteam)
- [modules/organization](#modulesorganization)
- [modules/environment](#modulesenvironment)
- [modules/actions](#modulesactions)
- [modules/webhook](#moduleswebhook)
- [modules/secrets](#modulessecrets)
- [modules/secrets-source-aws](#modulessecrets-source-aws)
- [modules/secrets-source-azure](#modulessecrets-source-azure)

---

## Baseline composite root

Source: `clouddrove/github-modules/github`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`, `hashicorp/random` `>= 3.9.0`, `hashicorp/time` `>= 0.14.1`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| archive\_on\_destroy | Archive rather than delete the repository on destroy. Deleting a repository is irreversible. | `bool` | `true` | no |
| collaborators | Repository access. Maps of username or team slug to permission (pull, triage, push, maintain, admin). | <pre>object({<br/>    users = optional(map(string), {})<br/>    teams = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| description | Repository description. | `string` | `""` | no |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| environments | Environments to create on the repository, keyed by environment name. | <pre>map(object({<br/>    wait_timer = optional(number)<br/>    reviewers = optional(object({<br/>      users = optional(list(number), [])<br/>      teams = optional(list(number), [])<br/>    }), {})<br/>    deployment_branch_policy = optional(object({<br/>      protected_branches     = bool<br/>      custom_branch_policies = bool<br/>    }))<br/>    branch_patterns = optional(list(string), [])<br/>  }))</pre> | `{}` | no |
| files | Files to manage in the repository, keyed by path. | <pre>map(object({<br/>    content             = string<br/>    branch              = optional(string)<br/>    commit_message      = optional(string)<br/>    commit_author       = optional(string)<br/>    commit_email        = optional(string)<br/>    overwrite_on_create = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| issue\_labels | Issue labels, keyed by label name. | <pre>map(object({<br/>    color       = string<br/>    description = optional(string)<br/>  }))</pre> | `{}` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| ruleset | Ruleset applied to the repository. Null skips ruleset creation. | <pre>object({<br/>    ruleset_name = string<br/>    target       = optional(string, "branch")<br/>    enforcement  = optional(string, "active")<br/>    conditions = optional(object({<br/>      ref_name = optional(object({<br/>        include = optional(list(string), ["~DEFAULT_BRANCH"])<br/>        exclude = optional(list(string), [])<br/>      }), {})<br/>    }), {})<br/>    rules = optional(any, {})<br/>  })</pre> | `null` | no |
| secret\_kinds | Default secret kinds to publish. One or more of actions, dependabot, codespaces. | `list(string)` | <pre>[<br/>  "actions"<br/>]</pre> | no |
| secrets | Secrets and variables to publish to GitHub, keyed by secret name.<br/>Set exactly one of `value` or `generate` per entry.<br/>Set `as_variable = true` to publish a GitHub Actions variable instead of a<br/>secret. Variables are not encrypted and are visible in workflow logs. | <pre>map(object({<br/>    value = optional(string)<br/>    generate = optional(object({<br/>      length           = optional(number, 32)<br/>      special          = optional(bool, true)<br/>      override_special = optional(string)<br/>      rotation_days    = optional(number)<br/>    }))<br/>    as_variable = optional(bool, false)<br/>    kinds       = optional(list(string))<br/>  }))</pre> | `{}` | no |
| topics | Topics applied to the repository. Topic names must be lowercase. | `list(string)` | `[]` | no |
| visibility | Repository visibility. One of public, private, internal. | `string` | `"private"` | no |
| vulnerability\_alerts | Enable Dependabot vulnerability alerts. | `bool` | `true` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| environment\_names | Environments created on the repository. | no |
| generated\_values | Generated secret values, keyed by secret name. | yes |
| repository\_full\_name | Full name of the created repository, owner/name. | no |
| repository\_name | Name of the created repository. | no |
| repository\_node\_id | GraphQL node ID of the created repository, needed by ruleset bypass actors. | no |
| ruleset\_id | ID of the repository ruleset, or null when no ruleset was requested. | no |
| secret\_names | Names of the secrets published to the repository. | no |
| variable\_names | Names of the GitHub Actions variables published to the repository. | no |

---

## wrappers

Source: `clouddrove/github-modules/github//wrappers`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`, `hashicorp/random` `>= 3.9.0`, `hashicorp/time` `>= 0.14.1`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| defaults | Values applied to every entry in `items` that does not set them itself. | `any` | `{}` | no |
| items | Baseline calls to make, keyed by an arbitrary label. Each value accepts any root module input; the key is used as the repository name when `name` is omitted. | `any` | `{}` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| repository\_names | Repository name created for each item label. | no |
| wrapper | All outputs of every baseline call, keyed by the item label. Sensitive because it carries generated secret values. | yes |

---

## modules/repository

Source: `clouddrove/github-modules/github//modules/repository`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| allow\_merge\_commit | Allow merge commits. | `bool` | `false` | no |
| allow\_rebase\_merge | Allow rebase merges. | `bool` | `false` | no |
| allow\_squash\_merge | Allow squash merges. | `bool` | `true` | no |
| app\_installation\_ids | GitHub App installation IDs to grant access to this repository. | `list(string)` | `[]` | no |
| archive\_on\_destroy | Archive rather than delete the repository on destroy. Deleting a repository is irreversible. | `bool` | `true` | no |
| auto\_init | Create an initial commit so the default branch exists. | `bool` | `true` | no |
| autolink\_references | Autolink references, keyed by key prefix, e.g. `JIRA-`. | <pre>map(object({<br/>    target_url_template = string<br/>    is_alphanumeric     = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| branches | Additional branches to create. | `list(string)` | `[]` | no |
| collaborators | Repository access. Maps of username or team slug to permission (pull, triage, push, maintain, admin). | <pre>object({<br/>    users = optional(map(string), {})<br/>    teams = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| custom\_properties | Organization custom property values, keyed by property name. `property_type` is one of string, single\_select, multi\_select, true\_false, url. Only multi\_select accepts more than one value. | <pre>map(object({<br/>    property_type  = string<br/>    property_value = list(string)<br/>  }))</pre> | `{}` | no |
| default\_branch | Name of the default branch. Null leaves the provider default. | `string` | `null` | no |
| delete\_branch\_on\_merge | Delete head branch after merge. | `bool` | `true` | no |
| dependabot\_security\_updates | Enable automated Dependabot security update pull requests. Requires vulnerability\_alerts. | `bool` | `true` | no |
| deploy\_keys | Deploy keys, keyed by title. | <pre>map(object({<br/>    key       = string<br/>    read_only = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| description | Repository description. | `string` | `""` | no |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| files | Files to manage in the repository, keyed by path. | <pre>map(object({<br/>    content             = string<br/>    branch              = optional(string)<br/>    commit_message      = optional(string)<br/>    commit_author       = optional(string)<br/>    commit_email        = optional(string)<br/>    overwrite_on_create = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| gitignore\_template | Name of a .gitignore template, e.g. `Terraform`. | `string` | `null` | no |
| has\_discussions | Enable Discussions. | `bool` | `false` | no |
| has\_issues | Enable GitHub Issues. | `bool` | `true` | no |
| has\_projects | Enable GitHub Projects. | `bool` | `false` | no |
| has\_wiki | Enable the wiki. | `bool` | `false` | no |
| homepage\_url | URL of a page describing the project. | `string` | `null` | no |
| issue\_labels | Issue labels, keyed by label name. | <pre>map(object({<br/>    color       = string<br/>    description = optional(string)<br/>  }))</pre> | `{}` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| license\_template | Name of a license template, e.g. `apache-2.0`. | `string` | `null` | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| template | Template repository to create this repository from. | <pre>object({<br/>    owner                = string<br/>    repository           = string<br/>    include_all_branches = optional(bool, false)<br/>  })</pre> | `null` | no |
| topics | Topics applied to the repository. Topic names must be lowercase. | `list(string)` | `[]` | no |
| visibility | Repository visibility. One of public, private, internal. | `string` | `"private"` | no |
| vulnerability\_alerts | Enable Dependabot vulnerability alerts. | `bool` | `true` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| default\_branch | Default branch name. | no |
| http\_clone\_url | HTTPS clone URL. | no |
| id | Composed name for this module instance. | no |
| repository\_full\_name | Full name of the repository, owner/name. | no |
| repository\_id | Numeric ID of the repository. | no |
| repository\_name | Name of the repository. | no |
| repository\_node\_id | GraphQL node ID of the repository, needed by ruleset bypass actors. | no |
| ssh\_clone\_url | SSH clone URL. | no |

---

## modules/ruleset

Source: `clouddrove/github-modules/github//modules/ruleset`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| branch\_protection | Classic branch protection, for repositories not yet migrated to rulesets. Keyed by an arbitrary label. | <pre>map(object({<br/>    pattern                         = string<br/>    enforce_admins                  = optional(bool, true)<br/>    require_signed_commits          = optional(bool, false)<br/>    required_linear_history         = optional(bool, true)<br/>    allows_deletions                = optional(bool, false)<br/>    allows_force_pushes             = optional(bool, false)<br/>    required_approving_review_count = optional(number, 1)<br/>  }))</pre> | `{}` | no |
| bypass\_actors | Actors allowed to bypass the ruleset. actor\_type is one of RepositoryRole, Team, Integration, OrganizationAdmin. | <pre>list(object({<br/>    actor_id    = number<br/>    actor_type  = string<br/>    bypass_mode = optional(string, "always")<br/>  }))</pre> | `[]` | no |
| conditions | Ruleset conditions. Use ~DEFAULT\_BRANCH or ~ALL in ref\_name.include. repository\_name applies to organization scope only. | <pre>object({<br/>    ref_name = optional(object({<br/>      include = optional(list(string), [])<br/>      exclude = optional(list(string), [])<br/>    }))<br/>    repository_name = optional(object({<br/>      include   = optional(list(string), [])<br/>      exclude   = optional(list(string), [])<br/>      protected = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| enforcement | Enforcement level. One of active, evaluate, disabled. | `string` | `"active"` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| repository | Repository the ruleset applies to. Required when scope is repository. | `string` | `null` | no |
| rules | Rules to enforce. Unset attributes are not enforced. | <pre>object({<br/>    creation                = optional(bool)<br/>    update                  = optional(bool)<br/>    deletion                = optional(bool)<br/>    required_linear_history = optional(bool)<br/>    required_signatures     = optional(bool)<br/>    non_fast_forward        = optional(bool)<br/>    pull_request = optional(object({<br/>      dismiss_stale_reviews_on_push     = optional(bool, true)<br/>      require_code_owner_review         = optional(bool, true)<br/>      require_last_push_approval        = optional(bool, false)<br/>      required_approving_review_count   = optional(number, 1)<br/>      required_review_thread_resolution = optional(bool, true)<br/>    }))<br/>    required_status_checks = optional(object({<br/>      strict_required_status_checks_policy = optional(bool, true)<br/>      required_check = list(object({<br/>        context        = string<br/>        integration_id = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | `{}` | no |
| ruleset\_name | Name of the ruleset. | `string` | `null` | no |
| scope | Ruleset scope. One of repository, organization. | `string` | `"repository"` | no |
| target | What the ruleset targets. One of branch, tag, push. | `string` | `"branch"` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| id | Composed name for this module instance. | no |
| ruleset\_id | ID of the created ruleset. | no |
| ruleset\_node\_id | GraphQL node ID of the created ruleset. | no |

---

## modules/team

Source: `clouddrove/github-modules/github//modules/team`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| create\_default\_maintainer | Whether the creating user becomes a maintainer. Leave false so membership is fully declarative. | `bool` | `false` | no |
| description | Team description. | `string` | `""` | no |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| members | Team members, mapping username to role. Role is one of member, maintainer. | `map(string)` | `{}` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| parent\_team\_id | Parent team ID or slug, for nested teams. | `string` | `null` | no |
| privacy | Team privacy. One of secret, closed. Nested teams require closed. | `string` | `"closed"` | no |
| repositories | Repository grants, mapping repository name to permission. One of pull, triage, push, maintain, admin. | `map(string)` | `{}` | no |
| review\_request\_delegation | Automatic review request delegation settings. | <pre>object({<br/>    algorithm    = optional(string, "ROUND_ROBIN")<br/>    member_count = optional(number, 1)<br/>    notify       = optional(bool, true)<br/>  })</pre> | `null` | no |
| sync\_group\_mapping | IdP groups to map to this team. Requires SAML or SCIM on the organization. | <pre>list(object({<br/>    group_id          = string<br/>    group_name        = string<br/>    group_description = optional(string, "")<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| id | Composed name for this module instance. | no |
| team\_id | Numeric ID of the team. | no |
| team\_node\_id | GraphQL node ID of the team, used as a ruleset bypass actor. | no |
| team\_slug | URL slug of the team, used in repository grants and CODEOWNERS. | no |

---

## modules/organization

Source: `clouddrove/github-modules/github//modules/organization`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| advanced\_security\_enabled\_for\_new\_repositories | Enable GitHub Advanced Security on new repositories. Requires a GHAS licence. | `bool` | `false` | no |
| billing\_email | Billing email for the organization. Required when manage\_settings is true. | `string` | `null` | no |
| blocked\_users | Usernames blocked from the organization. | `list(string)` | `[]` | no |
| blog | Organization website URL. | `string` | `null` | no |
| company | Company name shown on the organization profile. | `string` | `null` | no |
| custom\_properties | Organization custom properties, keyed by property name. | <pre>map(object({<br/>    value_type         = string<br/>    required           = optional(bool, false)<br/>    default_value      = optional(string)<br/>    description        = optional(string)<br/>    allowed_values     = optional(list(string))<br/>    values_editable_by = optional(string)<br/>  }))</pre> | `{}` | no |
| custom\_roles | Custom organization repository roles, keyed by role name. | <pre>map(object({<br/>    description = string<br/>    base_role   = string<br/>    permissions = list(string)<br/>  }))</pre> | `{}` | no |
| default\_repository\_permission | Base permission members get on all repositories. One of none, read, write, admin. | `string` | `"read"` | no |
| dependabot\_alerts\_enabled\_for\_new\_repositories | Enable Dependabot alerts on new repositories. | `bool` | `true` | no |
| email | Public email address for the organization. | `string` | `null` | no |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| location | Organization location. | `string` | `null` | no |
| manage\_settings | Whether to manage organization-wide settings. Set false to manage only membership and blocks. | `bool` | `true` | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| members | Organization membership, mapping username to role. One of member, admin. | `map(string)` | `{}` | no |
| members\_can\_create\_public\_repositories | Allow members to create public repositories. | `bool` | `false` | no |
| members\_can\_create\_repositories | Allow members to create repositories. | `bool` | `false` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| organization\_description | Organization description. | `string` | `null` | no |
| secret\_scanning\_enabled\_for\_new\_repositories | Enable secret scanning on new repositories. | `bool` | `true` | no |
| secret\_scanning\_push\_protection\_enabled\_for\_new\_repositories | Enable secret scanning push protection on new repositories. | `bool` | `true` | no |
| web\_commit\_signoff\_required | Require contributors to sign off on web-based commits. | `bool` | `true` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| id | Composed name for this module instance. | no |
| member\_usernames | Usernames whose membership this module manages. | no |
| organization\_id | ID of the managed organization settings resource. | no |

---

## modules/environment

Source: `clouddrove/github-modules/github//modules/environment`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| branch\_patterns | Branch name patterns allowed to deploy. Requires deployment\_branch\_policy.custom\_branch\_policies = true. | `list(string)` | `[]` | no |
| can\_admins\_bypass | Allow administrators to bypass the environment protection rules. | `bool` | `false` | no |
| deployment\_branch\_policy | Which branches may deploy. Exactly one of the two flags must be true. | <pre>object({<br/>    protected_branches     = bool<br/>    custom_branch_policies = bool<br/>  })</pre> | `null` | no |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| environment\_name | Environment name, for example prod or staging. | `string` | `null` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| prevent\_self\_review | Prevent the deployment actor from approving their own deployment. | `bool` | `true` | no |
| repository | Repository the environment belongs to. | `string` | `null` | no |
| reviewers | Required deployment reviewers, as numeric user and team IDs. | <pre>object({<br/>    users = optional(list(number), [])<br/>    teams = optional(list(number), [])<br/>  })</pre> | `{}` | no |
| tag\_patterns | Tag name patterns allowed to deploy. Requires deployment\_branch\_policy.custom\_branch\_policies = true. | `list(string)` | `[]` | no |
| wait\_timer | Minutes to delay a deployment. GitHub allows 0 to 43200. | `number` | `null` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| environment\_name | Name of the environment. | no |
| id | Composed name for this module instance. | no |
| repository | Repository the environment belongs to. | no |
| secrets\_target | Value to append to the secrets module's targets.environments list. | no |

---

## modules/actions

Source: `clouddrove/github-modules/github//modules/actions`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| organization\_oidc\_claim\_keys | Organization-wide OIDC subject claim keys. Empty leaves the GitHub default. | `list(string)` | `[]` | no |
| organization\_permissions | Organization-wide Actions permissions. | <pre>object({<br/>    allowed_actions      = optional(string, "selected")<br/>    enabled_repositories = optional(string, "all")<br/>    allowed_actions_config = optional(object({<br/>      github_owned_allowed = optional(bool, true)<br/>      verified_allowed     = optional(bool, false)<br/>      patterns_allowed     = optional(list(string), [])<br/>    }))<br/>    enabled_repository_ids = optional(list(number), [])<br/>  })</pre> | `null` | no |
| repository | Repository for repository-scoped settings. Null means organization scope only. | `string` | `null` | no |
| repository\_access\_level | Access level for a private repository's Actions workflows. One of none, user, organization. | `string` | `null` | no |
| repository\_oidc\_claim\_keys | Repository OIDC subject claim keys, for example ["repo", "context"]. Requires repository. Prefer OIDC federation over stored cloud credentials. | `list(string)` | `[]` | no |
| repository\_permissions | Repository-scoped Actions permissions. Requires repository. | <pre>object({<br/>    allowed_actions = optional(string, "selected")<br/>    enabled         = optional(bool, true)<br/>    allowed_actions_config = optional(object({<br/>      github_owned_allowed = optional(bool, true)<br/>      verified_allowed     = optional(bool, false)<br/>      patterns_allowed     = optional(list(string), [])<br/>    }))<br/>  })</pre> | `null` | no |
| runner\_groups | Self-hosted runner groups, keyed by group name. | <pre>map(object({<br/>    visibility                 = optional(string, "selected")<br/>    selected_repository_ids    = optional(list(number), [])<br/>    allows_public_repositories = optional(bool, false)<br/>    restricted_to_workflows    = optional(bool, false)<br/>    selected_workflows         = optional(list(string), [])<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| id | Composed name for this module instance. | no |
| runner\_group\_ids | IDs of the created runner groups, keyed by group name. | no |

---

## modules/webhook

Source: `clouddrove/github-modules/github//modules/webhook`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| repository | Repository the webhooks belong to. Required when scope is repository. | `string` | `null` | no |
| scope | Webhook scope. One of repository, organization. | `string` | `"repository"` | no |
| webhooks | Webhooks keyed by an arbitrary label. The `secret` value is stored in<br/>Terraform state in clear text; use encrypted remote state. | <pre>map(object({<br/>    url          = string<br/>    events       = list(string)<br/>    content_type = optional(string, "json")<br/>    secret       = optional(string)<br/>    insecure_ssl = optional(bool, false)<br/>    active       = optional(bool, true)<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| id | Composed name for this module instance. | no |
| webhook\_ids | IDs of the created webhooks, keyed by label. | no |
| webhook\_urls | Configured webhook URLs, keyed by label. Sensitive because URLs can embed tokens. | yes |

---

## modules/secrets

Source: `clouddrove/github-modules/github//modules/secrets`

Requires: Terraform `>= 1.10.0`, `integrations/github` `>= 6.13.0`, `hashicorp/random` `>= 3.9.0`, `hashicorp/time` `>= 0.14.1`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| kinds | Default secret kinds to publish. One or more of actions, dependabot, codespaces. | `list(string)` | <pre>[<br/>  "actions"<br/>]</pre> | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| secrets | Secrets and variables to publish to GitHub, keyed by secret name.<br/>Set exactly one of `value` or `generate` per entry.<br/>Set `as_variable = true` to publish a GitHub Actions variable instead of a<br/>secret. Variables are not encrypted and are visible in workflow logs. | <pre>map(object({<br/>    value = optional(string)<br/>    generate = optional(object({<br/>      length           = optional(number, 32)<br/>      special          = optional(bool, true)<br/>      override_special = optional(string)<br/>      rotation_days    = optional(number)<br/>    }))<br/>    as_variable = optional(bool, false)<br/>    kinds       = optional(list(string))<br/>  }))</pre> | `{}` | no |
| targets | Where to publish. Provide at least one target when secrets is non-empty. | <pre>object({<br/>    repositories = optional(list(string), [])<br/>    organization = optional(object({<br/>      visibility            = optional(string, "private")<br/>      selected_repositories = optional(list(string), [])<br/>    }))<br/>    environments = optional(list(object({<br/>      repository  = string<br/>      environment = string<br/>    })), [])<br/>  })</pre> | `{}` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| generated\_values | Generated secret values, keyed by secret name. Feed these to the resource that must accept the credential. | yes |
| id | Composed name for this module instance. | no |
| secret\_names | Names of all secrets published by this module. | no |
| variable\_names | Names of all GitHub Actions variables published by this module. | no |

---

## modules/secrets-source-aws

Source: `clouddrove/github-modules/github//modules/secrets-source-aws`

Requires: Terraform `>= 1.10.0`, `hashicorp/aws` `>= 5.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| secrets | Secrets to read from AWS, keyed by the GitHub secret name they will become.<br/>Set exactly one of `arn` (Secrets Manager) or `ssm_parameter` (SSM Parameter<br/>Store). `json_key` plucks one field from a JSON Secrets Manager secret and is<br/>valid only with `arn`. | <pre>map(object({<br/>    arn           = optional(string)<br/>    ssm_parameter = optional(string)<br/>    json_key      = optional(string)<br/>    version_id    = optional(string)<br/>    version_stage = optional(string)<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| id | Composed name for this module instance. | no |
| values | Resolved secret values, shaped for the secrets module's `secrets` input. Merge this into that map. | yes |

---

## modules/secrets-source-azure

Source: `clouddrove/github-modules/github//modules/secrets-source-azure`

Requires: Terraform `>= 1.10.0`, `hashicorp/azurerm` `>= 4.0`

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| enabled | Flag to control the resources creation. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| managedby | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| name | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| secrets | Secrets to read from Azure Key Vault, keyed by the GitHub secret name they<br/>will become. `name` is the secret name inside the vault. | <pre>map(object({<br/>    key_vault_id = string<br/>    name         = string<br/>    version      = optional(string)<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description | Sensitive |
| ---- | ----------- | :-------: |
| id | Composed name for this module instance. | no |
| values | Resolved secret values, shaped for the secrets module's `secrets` input. Merge this into that map. | yes |
