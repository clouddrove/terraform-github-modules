resource "github_repository" "this" {
  count = local.enabled_count

  name                   = local.id
  description            = var.description
  visibility             = var.visibility
  homepage_url           = var.homepage_url
  has_issues             = var.has_issues
  has_projects           = var.has_projects
  has_wiki               = var.has_wiki
  has_discussions        = var.has_discussions
  allow_merge_commit     = var.allow_merge_commit
  allow_squash_merge     = var.allow_squash_merge
  allow_rebase_merge     = var.allow_rebase_merge
  delete_branch_on_merge = var.delete_branch_on_merge
  auto_init              = var.auto_init
  gitignore_template     = var.gitignore_template
  license_template       = var.license_template
  archive_on_destroy     = var.archive_on_destroy

  dynamic "template" {
    for_each = var.template != null ? [var.template] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }
}

# Topics are owned by this resource rather than by the topics argument of
# github_repository, because the two write the same GitHub field and would
# fight over it.
##-----------------------------------------------------------------------------
## Dependabot vulnerability alerts. The `vulnerability_alerts` argument on
## github_repository is deprecated in provider 6.13.0 in favour of this resource.
##-----------------------------------------------------------------------------
resource "github_repository_vulnerability_alerts" "this" {
  count = local.enabled_count

  repository = github_repository.this[0].name
  enabled    = var.vulnerability_alerts
}

resource "github_repository_topics" "this" {
  count = var.enabled && length(var.topics) > 0 ? 1 : 0

  repository = github_repository.this[0].name
  topics     = var.topics
}

resource "github_repository_file" "this" {
  for_each = var.enabled ? var.files : {}

  repository          = github_repository.this[0].name
  file                = each.key
  content             = each.value.content
  branch              = each.value.branch
  commit_message      = each.value.commit_message
  commit_author       = each.value.commit_author
  commit_email        = each.value.commit_email
  overwrite_on_create = each.value.overwrite_on_create
}

resource "github_issue_label" "this" {
  for_each = var.enabled ? var.issue_labels : {}

  repository  = github_repository.this[0].name
  name        = each.key
  color       = each.value.color
  description = each.value.description
}

resource "github_repository_collaborators" "this" {
  count = var.enabled && (length(var.collaborators.users) > 0 || length(var.collaborators.teams) > 0) ? 1 : 0

  repository = github_repository.this[0].name

  dynamic "user" {
    for_each = var.collaborators.users
    content {
      username   = user.key
      permission = user.value
    }
  }

  dynamic "team" {
    for_each = var.collaborators.teams
    content {
      team_id    = team.key
      permission = team.value
    }
  }
}

resource "github_repository_deploy_key" "this" {
  for_each = var.enabled ? var.deploy_keys : {}

  repository = github_repository.this[0].name
  title      = each.key
  key        = each.value.key
  read_only  = each.value.read_only
}

resource "github_repository_autolink_reference" "this" {
  for_each = var.enabled ? var.autolink_references : {}

  repository          = github_repository.this[0].name
  key_prefix          = each.key
  target_url_template = each.value.target_url_template
  is_alphanumeric     = each.value.is_alphanumeric
}

resource "github_branch" "this" {
  for_each = var.enabled ? toset(var.branches) : toset([])

  repository = github_repository.this[0].name
  branch     = each.value
}

resource "github_branch_default" "this" {
  count = var.enabled && var.default_branch != null ? 1 : 0

  repository = github_repository.this[0].name
  branch     = var.default_branch

  depends_on = [github_branch.this]
}

resource "github_repository_dependabot_security_updates" "this" {
  count = local.enabled_count

  repository = github_repository.this[0].name
  enabled    = var.dependabot_security_updates
}

resource "github_repository_custom_property" "this" {
  for_each = var.enabled ? var.custom_properties : {}

  repository     = github_repository.this[0].name
  property_name  = each.key
  property_type  = each.value.property_type
  property_value = each.value.property_value
}

resource "github_app_installation_repository" "this" {
  for_each = var.enabled ? toset(var.app_installation_ids) : toset([])

  repository      = github_repository.this[0].name
  installation_id = each.value
}
