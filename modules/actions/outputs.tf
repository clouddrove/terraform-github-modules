output "runner_group_ids" {
  description = "IDs of the created runner groups, keyed by group name."
  value       = { for k, v in github_actions_runner_group.this : k => v.id }
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}
