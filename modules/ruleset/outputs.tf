output "ruleset_id" {
  description = "ID of the created ruleset."
  value       = try(github_repository_ruleset.this[0].ruleset_id, try(github_organization_ruleset.this[0].ruleset_id, null))
}

output "ruleset_node_id" {
  description = "GraphQL node ID of the created ruleset."
  value       = try(github_repository_ruleset.this[0].node_id, try(github_organization_ruleset.this[0].node_id, null))
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}
