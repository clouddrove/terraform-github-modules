output "values" {
  description = "Resolved secret values, shaped for the secrets module's `secrets` input. Merge this into that map."
  value       = { for k, v in local.resolved : k => { value = v } }
  sensitive   = true
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}
