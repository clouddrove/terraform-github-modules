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
  description = "Webhook scope. One of repository, organization."

  validation {
    condition     = contains(["repository", "organization"], var.scope)
    error_message = "scope must be one of repository, organization."
  }
}

variable "repository" {
  type        = string
  default     = null
  description = "Repository the webhooks belong to. Required when scope is repository."

  validation {
    condition     = var.scope != "repository" || var.repository != null
    error_message = "repository is required when scope is repository."
  }
}

variable "webhooks" {
  description = <<-EOT
    Webhooks keyed by an arbitrary label. The `secret` value is stored in
    Terraform state in clear text; use encrypted remote state.
  EOT

  type = map(object({
    url          = string
    events       = list(string)
    content_type = optional(string, "json")
    secret       = optional(string)
    insecure_ssl = optional(bool, false)
    active       = optional(bool, true)
  }))

  default = {}

  validation {
    condition     = alltrue([for k, v in var.webhooks : startswith(v.url, "https://")])
    error_message = "Webhook URLs must use https. Offending keys: ${join(", ", [for k, v in var.webhooks : k if !startswith(v.url, "https://")])}."
  }

  validation {
    condition     = alltrue([for k, v in var.webhooks : length(v.events) > 0])
    error_message = "Each webhook must subscribe to at least one event. Offending keys: ${join(", ", [for k, v in var.webhooks : k if length(v.events) == 0])}."
  }

  validation {
    condition     = alltrue([for k, v in var.webhooks : contains(["json", "form"], v.content_type)])
    error_message = "content_type must be one of json, form."
  }

  validation {
    condition     = alltrue([for k, v in var.webhooks : !v.insecure_ssl])
    error_message = "insecure_ssl disables TLS verification on webhook delivery and is not permitted. Fix the endpoint certificate instead."
  }
}
