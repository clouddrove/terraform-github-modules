output "generated_values" {
  description = "Generated secret values, keyed by secret name. Feed these to the resource that must accept the credential."
  value       = { for k, v in random_password.this : k => v.result }
  sensitive   = true
}

# Names are not secret and appear in plan output and the GitHub UI regardless.
# Without nonsensitive() they inherit the mark from a sensitive `secrets` map,
# forcing every consumer to unwrap them before use.
output "secret_names" {
  description = "Names of all secrets published by this module."
  value       = nonsensitive(sort(keys(local.secret_entries)))
}

output "variable_names" {
  description = "Names of all GitHub Actions variables published by this module."
  value       = nonsensitive(sort(keys(local.variable_entries)))
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}

