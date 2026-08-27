resource "github_repository_webhook" "this" {
  for_each = local.repository_webhooks

  repository = var.repository
  events     = each.value.events
  active     = each.value.active

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    secret       = each.value.secret
    insecure_ssl = each.value.insecure_ssl
  }
}

resource "github_organization_webhook" "this" {
  for_each = local.organization_webhooks

  events = each.value.events
  active = each.value.active

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    secret       = each.value.secret
    insecure_ssl = each.value.insecure_ssl
  }
}
