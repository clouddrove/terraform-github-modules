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

variable "repository" {
  type        = string
  default     = null
  description = "Repository for repository-scoped settings. Null means organization scope only."
}

variable "organization_permissions" {
  type = object({
    allowed_actions      = optional(string, "selected")
    enabled_repositories = optional(string, "all")
    allowed_actions_config = optional(object({
      github_owned_allowed = optional(bool, true)
      verified_allowed     = optional(bool, false)
      patterns_allowed     = optional(list(string), [])
    }))
    enabled_repository_ids = optional(list(number), [])
  })
  default     = null
  description = "Organization-wide Actions permissions."

  validation {
    condition = var.organization_permissions == null || contains(
      ["all", "local_only", "selected"],
      var.organization_permissions.allowed_actions
    )
    error_message = "allowed_actions must be one of all, local_only, selected."
  }

  validation {
    condition = var.organization_permissions == null || contains(
      ["all", "none", "selected"],
      var.organization_permissions.enabled_repositories
    )
    error_message = "enabled_repositories must be one of all, none, selected."
  }
}

variable "repository_permissions" {
  type = object({
    allowed_actions = optional(string, "selected")
    enabled         = optional(bool, true)
    allowed_actions_config = optional(object({
      github_owned_allowed = optional(bool, true)
      verified_allowed     = optional(bool, false)
      patterns_allowed     = optional(list(string), [])
    }))
  })
  default     = null
  description = "Repository-scoped Actions permissions. Requires repository."
}

variable "runner_groups" {
  type = map(object({
    visibility                 = optional(string, "selected")
    selected_repository_ids    = optional(list(number), [])
    allows_public_repositories = optional(bool, false)
    restricted_to_workflows    = optional(bool, false)
    selected_workflows         = optional(list(string), [])
  }))
  default     = {}
  description = "Self-hosted runner groups, keyed by group name."

  validation {
    condition     = alltrue([for k, v in var.runner_groups : contains(["all", "selected", "private"], v.visibility)])
    error_message = "Runner group visibility must be one of all, selected, private."
  }
}

variable "organization_oidc_claim_keys" {
  type        = list(string)
  default     = []
  description = "Organization-wide OIDC subject claim keys. Empty leaves the GitHub default."
}

variable "repository_oidc_claim_keys" {
  type        = list(string)
  default     = []
  description = "Repository OIDC subject claim keys, for example [\"repo\", \"context\"]. Requires repository. Prefer OIDC federation over stored cloud credentials."
}

variable "repository_access_level" {
  type        = string
  default     = null
  description = "Access level for a private repository's Actions workflows. One of none, user, organization."

  validation {
    condition     = var.repository_access_level == null || contains(["none", "user", "organization"], var.repository_access_level)
    error_message = "repository_access_level must be one of none, user, organization."
  }
}
