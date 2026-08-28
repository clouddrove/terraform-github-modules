##-----------------------------------------------------------------------------
## Stand-ins for the outputs of the module that creates the database. In a real
## root module these two are `module.rds.master_password` and
## `module.rds.endpoint`, wired straight from the producing module.
##-----------------------------------------------------------------------------
variable "rds_master_password" {
  type        = string
  sensitive   = true
  description = "Master password produced by the database module."
}

variable "rds_endpoint" {
  type        = string
  description = "Endpoint produced by the database module."
}
