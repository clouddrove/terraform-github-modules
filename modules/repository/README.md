# modules/repository

Creates and configures a single GitHub repository: settings, topics, files,
issue labels, collaborators, deploy keys, autolink references, branches,
custom property values, and GitHub App installations.

The repository name is composed from `label_order`, so `name = "api"` with
`environment = "prod"` produces `api-prod`.

## Destroying a repository

`archive_on_destroy` defaults to `true`. Deleting a GitHub repository is
irreversible and takes its issues, pull requests, and releases with it, so the
module archives instead. Set the flag to `false` only when you intend a real
deletion.

## Resources that own their own GitHub field

Two settings are managed by a dedicated resource rather than by an argument on
`github_repository`, because the provider deprecated the argument in 6.13.0
and the two writers would otherwise fight over the same field on every plan:

- Topics go through `github_repository_topics`, not the `topics` argument.
- Dependabot alerts go through `github_repository_vulnerability_alerts`, not
  the `vulnerability_alerts` argument.

## Usage

```hcl
module "repository" {
  source = "clouddrove/github-modules/github//modules/repository"

  name        = "api"
  environment = "prod"

  description = "API service"
  visibility  = "private"
  topics      = ["terraform", "api"]

  issue_labels = {
    bug = { color = "d73a4a", description = "Something is broken" }
  }

  files = {
    "CODEOWNERS" = { content = "* @clouddrove/platform" }
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
| [github_app_installation_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/app_installation_repository) | resource |
| [github_branch.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch) | resource |
| [github_branch_default.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_issue_label.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/issue_label) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_autolink_reference.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_autolink_reference) | resource |
| [github_repository_collaborators.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_collaborators) | resource |
| [github_repository_custom_property.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_custom_property) | resource |
| [github_repository_dependabot_security_updates.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_dependabot_security_updates) | resource |
| [github_repository_deploy_key.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key) | resource |
| [github_repository_file.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_topics.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_topics) | resource |
| [github_repository_vulnerability_alerts.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_vulnerability_alerts) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allow_merge_commit"></a> [allow\_merge\_commit](#input\_allow\_merge\_commit) | Allow merge commits. | `bool` | `false` | no |
| <a name="input_allow_rebase_merge"></a> [allow\_rebase\_merge](#input\_allow\_rebase\_merge) | Allow rebase merges. | `bool` | `false` | no |
| <a name="input_allow_squash_merge"></a> [allow\_squash\_merge](#input\_allow\_squash\_merge) | Allow squash merges. | `bool` | `true` | no |
| <a name="input_app_installation_ids"></a> [app\_installation\_ids](#input\_app\_installation\_ids) | GitHub App installation IDs to grant access to this repository. | `list(string)` | `[]` | no |
| <a name="input_archive_on_destroy"></a> [archive\_on\_destroy](#input\_archive\_on\_destroy) | Archive rather than delete the repository on destroy. Deleting a repository is irreversible. | `bool` | `true` | no |
| <a name="input_auto_init"></a> [auto\_init](#input\_auto\_init) | Create an initial commit so the default branch exists. | `bool` | `true` | no |
| <a name="input_autolink_references"></a> [autolink\_references](#input\_autolink\_references) | Autolink references, keyed by key prefix, e.g. `JIRA-`. | <pre>map(object({<br/>    target_url_template = string<br/>    is_alphanumeric     = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_branches"></a> [branches](#input\_branches) | Additional branches to create. | `list(string)` | `[]` | no |
| <a name="input_collaborators"></a> [collaborators](#input\_collaborators) | Repository access. Maps of username or team slug to permission (pull, triage, push, maintain, admin). | <pre>object({<br/>    users = optional(map(string), {})<br/>    teams = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_custom_properties"></a> [custom\_properties](#input\_custom\_properties) | Organization custom property values, keyed by property name. `property_type` is one of string, single\_select, multi\_select, true\_false, url. Only multi\_select accepts more than one value. | <pre>map(object({<br/>    property_type  = string<br/>    property_value = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Name of the default branch. Null leaves the provider default. | `string` | `null` | no |
| <a name="input_delete_branch_on_merge"></a> [delete\_branch\_on\_merge](#input\_delete\_branch\_on\_merge) | Delete head branch after merge. | `bool` | `true` | no |
| <a name="input_dependabot_security_updates"></a> [dependabot\_security\_updates](#input\_dependabot\_security\_updates) | Enable automated Dependabot security update pull requests. Requires vulnerability\_alerts. | `bool` | `true` | no |
| <a name="input_deploy_keys"></a> [deploy\_keys](#input\_deploy\_keys) | Deploy keys, keyed by title. | <pre>map(object({<br/>    key       = string<br/>    read_only = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Repository description. | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_files"></a> [files](#input\_files) | Files to manage in the repository, keyed by path. | <pre>map(object({<br/>    content             = string<br/>    branch              = optional(string)<br/>    commit_message      = optional(string)<br/>    commit_author       = optional(string)<br/>    commit_email        = optional(string)<br/>    overwrite_on_create = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_gitignore_template"></a> [gitignore\_template](#input\_gitignore\_template) | Name of a .gitignore template, e.g. `Terraform`. | `string` | `null` | no |
| <a name="input_has_discussions"></a> [has\_discussions](#input\_has\_discussions) | Enable Discussions. | `bool` | `false` | no |
| <a name="input_has_issues"></a> [has\_issues](#input\_has\_issues) | Enable GitHub Issues. | `bool` | `true` | no |
| <a name="input_has_projects"></a> [has\_projects](#input\_has\_projects) | Enable GitHub Projects. | `bool` | `false` | no |
| <a name="input_has_wiki"></a> [has\_wiki](#input\_has\_wiki) | Enable the wiki. | `bool` | `false` | no |
| <a name="input_homepage_url"></a> [homepage\_url](#input\_homepage\_url) | URL of a page describing the project. | `string` | `null` | no |
| <a name="input_issue_labels"></a> [issue\_labels](#input\_issue\_labels) | Issue labels, keyed by label name. | <pre>map(object({<br/>    color       = string<br/>    description = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_license_template"></a> [license\_template](#input\_license\_template) | Name of a license template, e.g. `apache-2.0`. | `string` | `null` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_template"></a> [template](#input\_template) | Template repository to create this repository from. | <pre>object({<br/>    owner                = string<br/>    repository           = string<br/>    include_all_branches = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Topics applied to the repository. Topic names must be lowercase. | `list(string)` | `[]` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Repository visibility. One of public, private, internal. | `string` | `"private"` | no |
| <a name="input_vulnerability_alerts"></a> [vulnerability\_alerts](#input\_vulnerability\_alerts) | Enable Dependabot vulnerability alerts. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_default_branch"></a> [default\_branch](#output\_default\_branch) | Default branch name. |
| <a name="output_http_clone_url"></a> [http\_clone\_url](#output\_http\_clone\_url) | HTTPS clone URL. |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_repository_full_name"></a> [repository\_full\_name](#output\_repository\_full\_name) | Full name of the repository, owner/name. |
| <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id) | Numeric ID of the repository. |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the repository. |
| <a name="output_repository_node_id"></a> [repository\_node\_id](#output\_repository\_node\_id) | GraphQL node ID of the repository, needed by ruleset bypass actors. |
| <a name="output_ssh_clone_url"></a> [ssh\_clone\_url](#output\_ssh\_clone\_url) | SSH clone URL. |
<!-- END_TF_DOCS -->
