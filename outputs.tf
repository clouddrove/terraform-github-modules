output "repository_name" {
  description = "Name of the created repository."
  value       = module.repository.repository_name
}

output "repository_full_name" {
  description = "Full name of the created repository, owner/name."
  value       = module.repository.repository_full_name
}

output "repository_node_id" {
  description = "GraphQL node ID of the created repository, needed by ruleset bypass actors."
  value       = module.repository.repository_node_id
}

output "ruleset_id" {
  description = "ID of the repository ruleset, or null when no ruleset was requested."
  value       = module.ruleset.ruleset_id
}

output "environment_names" {
  description = "Environments created on the repository."
  value       = sort(keys(module.environments))
}

output "secret_names" {
  description = "Names of the secrets published to the repository."
  value       = module.secrets.secret_names
}

output "variable_names" {
  description = "Names of the GitHub Actions variables published to the repository."
  value       = module.secrets.variable_names
}

output "generated_values" {
  description = "Generated secret values, keyed by secret name."
  value       = module.secrets.generated_values
  sensitive   = true
}
