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

variable "description" {
  type        = string
  default     = ""
  description = "Team description."
}

variable "privacy" {
  type        = string
  default     = "closed"
  description = "Team privacy. One of secret, closed. Nested teams require closed."

  validation {
    condition     = contains(["secret", "closed"], var.privacy)
    error_message = "privacy must be one of secret, closed."
  }
}

variable "parent_team_id" {
  type        = string
  default     = null
  description = "Parent team ID or slug, for nested teams."
}

variable "members" {
  type        = map(string)
  default     = {}
  description = "Team members, mapping username to role. Role is one of member, maintainer."

  validation {
    condition     = alltrue([for u, r in var.members : contains(["member", "maintainer"], r)])
    error_message = "Member roles must be one of member, maintainer."
  }
}

variable "repositories" {
  type        = map(string)
  default     = {}
  description = "Repository grants, mapping repository name to permission. One of pull, triage, push, maintain, admin."

  validation {
    condition     = alltrue([for r, p in var.repositories : contains(["pull", "triage", "push", "maintain", "admin"], p)])
    error_message = "Repository permissions must be one of pull, triage, push, maintain, admin."
  }
}

variable "review_request_delegation" {
  type = object({
    algorithm    = optional(string, "ROUND_ROBIN")
    member_count = optional(number, 1)
    notify       = optional(bool, true)
  })
  default     = null
  description = "Automatic review request delegation settings."
}

variable "sync_group_mapping" {
  type = list(object({
    group_id          = string
    group_name        = string
    group_description = optional(string, "")
  }))
  default     = []
  description = "IdP groups to map to this team. Requires SAML or SCIM on the organization."
}

variable "create_default_maintainer" {
  type        = bool
  default     = false
  description = "Whether the creating user becomes a maintainer. Leave false so membership is fully declarative."
}
