output "repository_name" {
  description = "Name of the repository."
  value       = local.repository_name
}

output "repository_full_name" {
  description = "Full name of the repository, owner/name."
  value       = try(github_repository.this[0].full_name, null)
}

output "repository_node_id" {
  description = "GraphQL node ID of the repository, needed by ruleset bypass actors."
  value       = try(github_repository.this[0].node_id, null)
}

output "repository_id" {
  description = "Numeric ID of the repository."
  value       = try(github_repository.this[0].repo_id, null)
}

output "default_branch" {
  description = "Default branch name."
  value       = try(github_repository.this[0].default_branch, null)
}

output "ssh_clone_url" {
  description = "SSH clone URL."
  value       = try(github_repository.this[0].ssh_clone_url, null)
}

output "http_clone_url" {
  description = "HTTPS clone URL."
  value       = try(github_repository.this[0].http_clone_url, null)
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}
