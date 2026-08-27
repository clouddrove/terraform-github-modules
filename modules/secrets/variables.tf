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

  validation {
    condition     = alltrue([for k, v in var.secrets : can(regex("^[A-Z_][A-Z0-9_]*$", k))])
    error_message = "Secret names must match ^[A-Z_][A-Z0-9_]*$. Offending names: ${join(", ", [for k, v in var.secrets : k if !can(regex("^[A-Z_][A-Z0-9_]*$", k))])}."
  }

  validation {
    condition     = alltrue([for k, v in var.secrets : !startswith(k, "GITHUB_")])
    error_message = "GitHub rejects secret names starting with GITHUB_. Offending names: ${join(", ", [for k, v in var.secrets : k if startswith(k, "GITHUB_")])}."
  }

  validation {
    condition     = alltrue([for k, v in var.secrets : (v.value != null) != (v.generate != null)])
    error_message = "Set exactly one of value or generate. Offending names: ${join(", ", [for k, v in var.secrets : k if(v.value != null) == (v.generate != null)])}."
  }

  validation {
    condition     = alltrue([for k, v in var.secrets : !(v.as_variable && v.generate != null)])
    error_message = "as_variable cannot be combined with generate, because GitHub variables are not encrypted. Offending names: ${join(", ", [for k, v in var.secrets : k if v.as_variable && v.generate != null])}."
  }

  validation {
    condition = alltrue([
      for k, v in var.secrets : alltrue([
        for kind in coalesce(v.kinds, []) : contains(["actions", "dependabot", "codespaces"], kind)
      ])
    ])
    error_message = "Per-secret kinds must each be one of actions, dependabot, codespaces."
  }
}

variable "kinds" {
  type        = list(string)
  default     = ["actions"]
  description = "Default secret kinds to publish. One or more of actions, dependabot, codespaces."

  validation {
    condition     = alltrue([for kind in var.kinds : contains(["actions", "dependabot", "codespaces"], kind)])
    error_message = "kinds must each be one of actions, dependabot, codespaces."
  }
}

variable "targets" {
  description = "Where to publish. Provide at least one target when secrets is non-empty."

  type = object({
    repositories = optional(list(string), [])
    organization = optional(object({
      visibility            = optional(string, "private")
      selected_repositories = optional(list(string), [])
    }))
    environments = optional(list(object({
      repository  = string
      environment = string
    })), [])
  })

  default = {}

  validation {
    condition     = var.targets.organization == null ? true : contains(["all", "private", "selected"], var.targets.organization.visibility)
    error_message = "targets.organization.visibility must be one of all, private, selected."
  }

  validation {
    condition = (
      var.targets.organization == null ? true :
      var.targets.organization.visibility != "selected" || length(var.targets.organization.selected_repositories) > 0
    )
    error_message = "targets.organization.selected_repositories must be non-empty when visibility is selected."
  }
}
