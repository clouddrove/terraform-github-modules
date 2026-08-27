variable "enabled" {
  type        = bool
  default     = true
  description = "Flag to control the resources creation."
}

variable "name" {
  type        = string
  default     = ""
  description = "Name (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`environment`."
}

# Part of the standard module interface. GitHub resources carry no tags, so
# this value is informational only.
variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'."
}

variable "description" {
  type        = string
  default     = ""
  description = "Repository description."
}

variable "visibility" {
  type        = string
  default     = "private"
  description = "Repository visibility. One of public, private, internal."

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be one of public, private, internal."
  }
}

variable "homepage_url" {
  type        = string
  default     = null
  description = "URL of a page describing the project."
}

variable "topics" {
  type        = list(string)
  default     = []
  description = "Topics applied to the repository. Topic names must be lowercase."
}

variable "has_issues" {
  type        = bool
  default     = true
  description = "Enable GitHub Issues."
}

variable "has_projects" {
  type        = bool
  default     = false
  description = "Enable GitHub Projects."
}

variable "has_wiki" {
  type        = bool
  default     = false
  description = "Enable the wiki."
}

variable "has_discussions" {
  type        = bool
  default     = false
  description = "Enable Discussions."
}

variable "allow_merge_commit" {
  type        = bool
  default     = false
  description = "Allow merge commits."
}

variable "allow_squash_merge" {
  type        = bool
  default     = true
  description = "Allow squash merges."
}

variable "allow_rebase_merge" {
  type        = bool
  default     = false
  description = "Allow rebase merges."
}

variable "delete_branch_on_merge" {
  type        = bool
  default     = true
  description = "Delete head branch after merge."
}

variable "auto_init" {
  type        = bool
  default     = true
  description = "Create an initial commit so the default branch exists."
}

variable "gitignore_template" {
  type        = string
  default     = null
  description = "Name of a .gitignore template, e.g. `Terraform`."
}

variable "license_template" {
  type        = string
  default     = null
  description = "Name of a license template, e.g. `apache-2.0`."
}

variable "archive_on_destroy" {
  type        = bool
  default     = true
  description = "Archive rather than delete the repository on destroy. Deleting a repository is irreversible."
}

variable "vulnerability_alerts" {
  type        = bool
  default     = true
  description = "Enable Dependabot vulnerability alerts."
}

variable "dependabot_security_updates" {
  type        = bool
  default     = true
  description = "Enable automated Dependabot security update pull requests. Requires vulnerability_alerts."
}

variable "template" {
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default     = null
  description = "Template repository to create this repository from."
}

variable "default_branch" {
  type        = string
  default     = null
  description = "Name of the default branch. Null leaves the provider default."
}

variable "branches" {
  type        = list(string)
  default     = []
  description = "Additional branches to create."
}

variable "files" {
  type = map(object({
    content             = string
    branch              = optional(string)
    commit_message      = optional(string)
    commit_author       = optional(string)
    commit_email        = optional(string)
    overwrite_on_create = optional(bool, false)
  }))
  default     = {}
  description = "Files to manage in the repository, keyed by path."

  validation {
    condition     = alltrue([for k, v in var.files : (v.commit_author == null) == (v.commit_email == null)])
    error_message = "Set commit_author and commit_email together or set neither. Offending paths: ${join(", ", [for k, v in var.files : k if(v.commit_author == null) != (v.commit_email == null)])}."
  }
}

variable "issue_labels" {
  type = map(object({
    color       = string
    description = optional(string)
  }))
  default     = {}
  description = "Issue labels, keyed by label name."

  validation {
    condition     = alltrue([for k, v in var.issue_labels : can(regex("^[0-9a-fA-F]{6}$", v.color))])
    error_message = "Label color must be a six digit hex value without a leading #."
  }
}

variable "collaborators" {
  type = object({
    users = optional(map(string), {})
    teams = optional(map(string), {})
  })
  default     = {}
  description = "Repository access. Maps of username or team slug to permission (pull, triage, push, maintain, admin)."

  validation {
    condition = alltrue([
      for k, v in merge(var.collaborators.users, var.collaborators.teams) :
      contains(["pull", "triage", "push", "maintain", "admin"], v)
    ])
    error_message = "Collaborator permission must be one of pull, triage, push, maintain, admin."
  }
}

variable "deploy_keys" {
  type = map(object({
    key       = string
    read_only = optional(bool, true)
  }))
  default     = {}
  description = "Deploy keys, keyed by title."
}

variable "autolink_references" {
  type = map(object({
    target_url_template = string
    is_alphanumeric     = optional(bool, true)
  }))
  default     = {}
  description = "Autolink references, keyed by key prefix, e.g. `JIRA-`."
}

variable "custom_properties" {
  type = map(object({
    property_type  = string
    property_value = list(string)
  }))
  default     = {}
  description = "Organization custom property values, keyed by property name. `property_type` is one of string, single_select, multi_select, true_false, url. Only multi_select accepts more than one value."

  validation {
    condition = alltrue([
      for k, v in var.custom_properties :
      contains(["string", "single_select", "multi_select", "true_false", "url"], v.property_type)
    ])
    error_message = "custom_properties property_type must be one of string, single_select, multi_select, true_false, url."
  }

  validation {
    condition = alltrue([
      for k, v in var.custom_properties :
      v.property_type == "multi_select" || length(v.property_value) == 1
    ])
    error_message = "Only a multi_select custom property may carry more than one value."
  }
}

variable "app_installation_ids" {
  type        = list(string)
  default     = []
  description = "GitHub App installation IDs to grant access to this repository."
}
