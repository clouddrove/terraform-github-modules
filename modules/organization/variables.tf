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

variable "manage_settings" {
  type        = bool
  default     = true
  description = "Whether to manage organization-wide settings. Set false to manage only membership and blocks."
}

variable "billing_email" {
  type        = string
  default     = null
  description = "Billing email for the organization. Required when manage_settings is true."

  validation {
    condition     = !var.manage_settings || var.billing_email != null
    error_message = "billing_email is required when manage_settings is true."
  }
}

variable "company" {
  type        = string
  default     = null
  description = "Company name shown on the organization profile."
}

variable "blog" {
  type        = string
  default     = null
  description = "Organization website URL."
}

variable "email" {
  type        = string
  default     = null
  description = "Public email address for the organization."
}

variable "location" {
  type        = string
  default     = null
  description = "Organization location."
}

variable "organization_description" {
  type        = string
  default     = null
  description = "Organization description."
}

variable "default_repository_permission" {
  type        = string
  default     = "read"
  description = "Base permission members get on all repositories. One of none, read, write, admin."

  validation {
    condition     = contains(["none", "read", "write", "admin"], var.default_repository_permission)
    error_message = "default_repository_permission must be one of none, read, write, admin."
  }
}

variable "members_can_create_repositories" {
  type        = bool
  default     = false
  description = "Allow members to create repositories."
}

variable "members_can_create_public_repositories" {
  type        = bool
  default     = false
  description = "Allow members to create public repositories."
}

variable "web_commit_signoff_required" {
  type        = bool
  default     = true
  description = "Require contributors to sign off on web-based commits."
}

variable "advanced_security_enabled_for_new_repositories" {
  type        = bool
  default     = false
  description = "Enable GitHub Advanced Security on new repositories. Requires a GHAS licence."
}

variable "dependabot_alerts_enabled_for_new_repositories" {
  type        = bool
  default     = true
  description = "Enable Dependabot alerts on new repositories."
}

variable "secret_scanning_enabled_for_new_repositories" {
  type        = bool
  default     = true
  description = "Enable secret scanning on new repositories."
}

variable "secret_scanning_push_protection_enabled_for_new_repositories" {
  type        = bool
  default     = true
  description = "Enable secret scanning push protection on new repositories."
}

variable "members" {
  type        = map(string)
  default     = {}
  description = "Organization membership, mapping username to role. One of member, admin."

  validation {
    condition     = alltrue([for u, r in var.members : contains(["member", "admin"], r)])
    error_message = "Member roles must be one of member, admin."
  }
}

variable "blocked_users" {
  type        = list(string)
  default     = []
  description = "Usernames blocked from the organization."
}

variable "custom_roles" {
  type = map(object({
    description = string
    base_role   = string
    permissions = list(string)
  }))
  default     = {}
  description = "Custom organization repository roles, keyed by role name."
}

variable "custom_properties" {
  type = map(object({
    value_type         = string
    required           = optional(bool, false)
    default_value      = optional(string)
    description        = optional(string)
    allowed_values     = optional(list(string))
    values_editable_by = optional(string)
  }))
  default     = {}
  description = "Organization custom properties, keyed by property name."
}
