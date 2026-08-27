output "webhook_urls" {
  description = "Configured webhook URLs, keyed by label. Sensitive because URLs can embed tokens."
  value       = { for k, v in var.webhooks : k => v.url }
  sensitive   = true
}

output "webhook_ids" {
  description = "IDs of the created webhooks, keyed by label."
  value = merge(
    { for k, v in github_repository_webhook.this : k => v.id },
    { for k, v in github_organization_webhook.this : k => v.id },
  )
}

output "id" {
  description = "Composed name for this module instance."
  value       = local.id
}

