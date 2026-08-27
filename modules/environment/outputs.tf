output "environment_name" {
  description = "Name of the environment."
  value       = try(github_repository_environment.this[0].environment, null)
}

output "repository" {
  description = "Repository the environment belongs to."
  value       = var.repository
}

output "secrets_target" {
  description = "Value to append to the secrets module's targets.environments list."
  value = var.enabled ? {
    repository  = var.repository
    environment = var.environment_name
  } : null
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}
