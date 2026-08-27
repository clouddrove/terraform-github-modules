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
    Secrets to read from Azure Key Vault, keyed by the GitHub secret name they
    will become. `name` is the secret name inside the vault.
  EOT

  type = map(object({
    key_vault_id = string
    name         = string
    version      = optional(string)
  }))

  default = {}

  validation {
    condition     = alltrue([for k, v in var.secrets : can(regex("^[A-Z_][A-Z0-9_]*$", k))])
    error_message = "Keys become GitHub secret names and must match ^[A-Z_][A-Z0-9_]*$."
  }
}
