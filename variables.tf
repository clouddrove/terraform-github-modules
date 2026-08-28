##-----------------------------------------------------------------------------
## Standard module interface.
##-----------------------------------------------------------------------------
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

##-----------------------------------------------------------------------------
## Repository pass-throughs. Types are copied from modules/repository so the
## two cannot drift.
##-----------------------------------------------------------------------------
variable "description" {
  type        = string
  default     = ""
  description = "Repository description."
}

variable "visibility" {
  type        = string
  default     = "private"
  description = "Repository visibility. One of public, private, internal."
}

variable "topics" {
  type        = list(string)
  default     = []
  description = "Topics applied to the repository. Topic names must be lowercase."
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
}

variable "issue_labels" {
  type = map(object({
    color       = string
    description = optional(string)
  }))
  default     = {}
  description = "Issue labels, keyed by label name."
}

variable "collaborators" {
  type = object({
    users = optional(map(string), {})
    teams = optional(map(string), {})
  })
  default     = {}
  description = "Repository access. Maps of username or team slug to permission (pull, triage, push, maintain, admin)."
}

variable "vulnerability_alerts" {
  type        = bool
  default     = true
  description = "Enable Dependabot vulnerability alerts."
}

variable "archive_on_destroy" {
  type        = bool
  default     = true
  description = "Archive rather than delete the repository on destroy. Deleting a repository is irreversible."
}

##-----------------------------------------------------------------------------
## Ruleset.
##-----------------------------------------------------------------------------
variable "ruleset" {
  type = object({
    ruleset_name = string
    target       = optional(string, "branch")
    enforcement  = optional(string, "active")
    conditions = optional(object({
      ref_name = optional(object({
        include = optional(list(string), ["~DEFAULT_BRANCH"])
        exclude = optional(list(string), [])
      }), {})
    }), {})
    rules = optional(any, {})
  })
  default     = null
  description = "Ruleset applied to the repository. Null skips ruleset creation."
}

##-----------------------------------------------------------------------------
## Environments.
##-----------------------------------------------------------------------------
variable "environments" {
  type = map(object({
    wait_timer = optional(number)
    reviewers = optional(object({
      users = optional(list(number), [])
      teams = optional(list(number), [])
    }), {})
    deployment_branch_policy = optional(object({
      protected_branches     = bool
      custom_branch_policies = bool
    }))
    branch_patterns = optional(list(string), [])
  }))
  default     = {}
  description = "Environments to create on the repository, keyed by environment name."
}

##-----------------------------------------------------------------------------
## Secrets. Types are copied from modules/secrets.
##-----------------------------------------------------------------------------
variable "secrets" {
  description = <<-EOT
    Secrets and variables to publish to GitHub, keyed by secret name.
    Set exactly one of `value` or `generate` per entry.
    Set `as_variable = true` to publish a GitHub Actions variable instead of a
    secret. Variables are not encrypted and are visible in workflow logs.
  EOT

  type = map(object({
    value = optional(string)
    generate = optional(object({
      length           = optional(number, 32)
      special          = optional(bool, true)
      override_special = optional(string)
      rotation_days    = optional(number)
    }))
    as_variable = optional(bool, false)
    kinds       = optional(list(string))
  }))

  default = {}
}

variable "secret_kinds" {
  type        = list(string)
  default     = ["actions"]
  description = "Default secret kinds to publish. One or more of actions, dependabot, codespaces."
}
