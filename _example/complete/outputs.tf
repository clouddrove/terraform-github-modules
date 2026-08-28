output "repository_full_name" {
  description = "Full name of the repository, owner/name."
  value       = module.baseline.repository_full_name
}

output "environment_names" {
  description = "Environments created on the repository."
  value       = module.baseline.environment_names
}

output "secret_names" {
  description = "Names of every secret published to the repository."
  value       = module.baseline.secret_names
}

output "team_slug" {
  description = "Slug of the owning team."
  value       = module.team.team_slug
}

output "runner_group_ids" {
  description = "IDs of the self-hosted runner groups, keyed by group name."
  value       = module.actions.runner_group_ids
}

output "webhook_ids" {
  description = "IDs of the repository webhooks, keyed by label."
  value       = module.webhook.webhook_ids
}
