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
  description = "Repository the environment belongs to."
}

variable "environment_name" {
  type        = string
  default     = null
  description = "Environment name, for example prod or staging."
}

variable "wait_timer" {
  type        = number
  default     = null
  description = "Minutes to delay a deployment. GitHub allows 0 to 43200."

  validation {
    condition     = var.wait_timer == null || (var.wait_timer >= 0 && var.wait_timer <= 43200)
    error_message = "wait_timer must be between 0 and 43200 minutes."
  }
}

variable "prevent_self_review" {
  type        = bool
  default     = true
  description = "Prevent the deployment actor from approving their own deployment."
}

variable "can_admins_bypass" {
  type        = bool
  default     = false
  description = "Allow administrators to bypass the environment protection rules."
}

variable "reviewers" {
  type = object({
    users = optional(list(number), [])
    teams = optional(list(number), [])
  })
  default     = {}
  description = "Required deployment reviewers, as numeric user and team IDs."
}

variable "deployment_branch_policy" {
  type = object({
    protected_branches     = bool
    custom_branch_policies = bool
  })
  default     = null
  description = "Which branches may deploy. Exactly one of the two flags must be true."

  validation {
    condition     = var.deployment_branch_policy == null || (var.deployment_branch_policy.protected_branches != var.deployment_branch_policy.custom_branch_policies)
    error_message = "Exactly one of protected_branches or custom_branch_policies must be true."
  }
}

variable "branch_patterns" {
  type        = list(string)
  default     = []
  description = "Branch name patterns allowed to deploy. Requires deployment_branch_policy.custom_branch_policies = true."

  validation {
    condition = (
      length(var.branch_patterns) == 0 ||
      (var.deployment_branch_policy != null && var.deployment_branch_policy.custom_branch_policies)
    )
    error_message = "branch_patterns requires deployment_branch_policy.custom_branch_policies = true."
  }
}

variable "tag_patterns" {
  type        = list(string)
  default     = []
  description = "Tag name patterns allowed to deploy. Requires deployment_branch_policy.custom_branch_policies = true."

  validation {
    condition = (
      length(var.tag_patterns) == 0 ||
      (var.deployment_branch_policy != null && var.deployment_branch_policy.custom_branch_policies)
    )
    error_message = "tag_patterns requires deployment_branch_policy.custom_branch_policies = true."
  }
}
