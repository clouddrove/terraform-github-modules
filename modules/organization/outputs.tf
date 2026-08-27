output "organization_id" {
  description = "ID of the managed organization settings resource."
  value       = try(github_organization_settings.this[0].id, null)
}

output "member_usernames" {
  description = "Usernames whose membership this module manages."
  value       = sort(keys(var.members))
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}
