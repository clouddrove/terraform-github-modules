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

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'."
}

variable "scope" {
  type        = string
  default     = "repository"
  description = "Ruleset scope. One of repository, organization."

  validation {
    condition     = contains(["repository", "organization"], var.scope)
    error_message = "scope must be one of repository, organization."
  }
}

variable "repository" {
  type        = string
  default     = null
  description = "Repository the ruleset applies to. Required when scope is repository."

  validation {
    condition     = var.scope != "repository" || var.repository != null
    error_message = "repository is required when scope is repository."
  }
}

variable "ruleset_name" {
  type        = string
  default     = null
  description = "Name of the ruleset."
}

variable "target" {
  type        = string
  default     = "branch"
  description = "What the ruleset targets. One of branch, tag, push."

  validation {
    condition     = contains(["branch", "tag", "push"], var.target)
    error_message = "target must be one of branch, tag, push."
  }
}

variable "enforcement" {
  type        = string
  default     = "active"
  description = "Enforcement level. One of active, evaluate, disabled."

  validation {
    condition     = contains(["active", "evaluate", "disabled"], var.enforcement)
    error_message = "enforcement must be one of active, evaluate, disabled."
  }
}

variable "conditions" {
  type = object({
    ref_name = optional(object({
      include = optional(list(string), [])
      exclude = optional(list(string), [])
    }))
    repository_name = optional(object({
      include   = optional(list(string), [])
      exclude   = optional(list(string), [])
      protected = optional(bool)
    }))
  })
  default     = null
  description = "Ruleset conditions. Use ~DEFAULT_BRANCH or ~ALL in ref_name.include. repository_name applies to organization scope only."
}

variable "bypass_actors" {
  type = list(object({
    actor_id    = number
    actor_type  = string
    bypass_mode = optional(string, "always")
  }))
  default     = []
  description = "Actors allowed to bypass the ruleset. actor_type is one of RepositoryRole, Team, Integration, OrganizationAdmin."
}

variable "rules" {
  type = object({
    creation                = optional(bool)
    update                  = optional(bool)
    deletion                = optional(bool)
    required_linear_history = optional(bool)
    required_signatures     = optional(bool)
    non_fast_forward        = optional(bool)
    pull_request = optional(object({
      dismiss_stale_reviews_on_push     = optional(bool, true)
      require_code_owner_review         = optional(bool, true)
      require_last_push_approval        = optional(bool, false)
      required_approving_review_count   = optional(number, 1)
      required_review_thread_resolution = optional(bool, true)
    }))
    required_status_checks = optional(object({
      strict_required_status_checks_policy = optional(bool, true)
      required_check = list(object({
        context        = string
        integration_id = optional(number)
      }))
    }))
  })
  default     = {}
  description = "Rules to enforce. Unset attributes are not enforced."
}

variable "branch_protection" {
  type = map(object({
    pattern                         = string
    enforce_admins                  = optional(bool, true)
    require_signed_commits          = optional(bool, true)
    required_linear_history         = optional(bool, true)
    allows_deletions                = optional(bool, false)
    allows_force_pushes             = optional(bool, false)
    required_approving_review_count = optional(number, 2)
  }))
  default     = {}
  description = "Classic branch protection, for repositories not yet migrated to rulesets. Keyed by an arbitrary label. Defaults are secure-by-default: signed commits required and two approving reviews. Lower them explicitly per entry if a repository cannot meet them."
}
