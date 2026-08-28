output "wrapper" {
  description = "All outputs of every baseline call, keyed by the item label. Sensitive because it carries generated secret values."
  value       = { for k, v in module.wrapper : k => v }
  sensitive   = true
}

output "repository_names" {
  description = "Repository name created for each item label."
  value       = { for k, v in module.wrapper : k => v.repository_name }
}
