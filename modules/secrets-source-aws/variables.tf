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
    Secrets to read from AWS, keyed by the GitHub secret name they will become.
    Set exactly one of `arn` (Secrets Manager) or `ssm_parameter` (SSM Parameter
    Store). `json_key` plucks one field from a JSON Secrets Manager secret and is
    valid only with `arn`.
  EOT

  type = map(object({
    arn           = optional(string)
    ssm_parameter = optional(string)
    json_key      = optional(string)
    version_id    = optional(string)
    version_stage = optional(string)
  }))

  default = {}

  validation {
    condition     = alltrue([for k, v in var.secrets : (v.arn != null) != (v.ssm_parameter != null)])
    error_message = "Set exactly one of arn or ssm_parameter. Offending names: ${join(", ", [for k, v in var.secrets : k if(v.arn != null) == (v.ssm_parameter != null)])}."
  }

  validation {
    condition     = alltrue([for k, v in var.secrets : v.json_key == null || v.arn != null])
    error_message = "json_key is only valid with arn, because SSM parameters are plain strings. Offending names: ${join(", ", [for k, v in var.secrets : k if v.json_key != null && v.arn == null])}."
  }

  validation {
    condition     = alltrue([for k, v in var.secrets : can(regex("^[A-Z_][A-Z0-9_]*$", k))])
    error_message = "Keys become GitHub secret names and must match ^[A-Z_][A-Z0-9_]*$."
  }
}
