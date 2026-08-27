output "generated_values" {
  description = "Generated secret values, keyed by secret name. Feed these to the resource that must accept the credential."
  value       = { for k, v in random_password.this : k => v.result }
  sensitive   = true
}

output "secret_names" {
  description = "Names of all secrets published by this module."
  value       = sort(keys(local.secret_entries))
}

output "variable_names" {
  description = "Names of all GitHub Actions variables published by this module."
  value       = sort(keys(local.variable_entries))
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}

