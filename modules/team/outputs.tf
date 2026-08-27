output "team_id" {
  description = "Numeric ID of the team."
  value       = try(github_team.this[0].id, null)
}

output "team_slug" {
  description = "URL slug of the team, used in repository grants and CODEOWNERS."
  value       = try(local.team_slug, null)
}

output "team_node_id" {
  description = "GraphQL node ID of the team, used as a ruleset bypass actor."
  value       = try(github_team.this[0].node_id, null)
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}
