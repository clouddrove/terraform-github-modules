##-----------------------------------------------------------------------------
## The team itself. create_default_maintainer stays false by default so that
## membership is driven entirely by the members variable.
##-----------------------------------------------------------------------------
resource "github_team" "this" {
  count = local.enabled_count

  name           = local.id
  description    = var.description
  privacy        = var.privacy
  parent_team_id = var.parent_team_id
  # Deprecated in 6.13.0 ("use github_team_members instead"), which is what this
  # module already does. Kept deliberately: setting it false actively removes the
  # creating user, while omitting it risks GitHub's API default of adding the team
  # creator as a maintainer. A plan warning is cheaper than silent membership drift.
  create_default_maintainer = var.create_default_maintainer
}

##-----------------------------------------------------------------------------
## Authoritative team membership.
##-----------------------------------------------------------------------------
resource "github_team_members" "this" {
  count = var.enabled && length(var.members) > 0 ? 1 : 0

  # team_id is deprecated on this resource in provider 6.13.0; team_slug is the
  # supported argument. github_team_settings still requires team_id.
  team_slug = github_team.this[0].slug

  dynamic "members" {
    for_each = var.members
    content {
      username = members.key
      role     = members.value
    }
  }
}

##-----------------------------------------------------------------------------
## Repository grants.
##-----------------------------------------------------------------------------
resource "github_team_repository" "this" {
  for_each = var.enabled ? var.repositories : {}

  team_id    = github_team.this[0].id
  repository = each.key
  permission = each.value
}

##-----------------------------------------------------------------------------
## Automatic review request delegation.
##-----------------------------------------------------------------------------
resource "github_team_settings" "this" {
  count = var.enabled && var.review_request_delegation != null ? 1 : 0

  team_id = github_team.this[0].id

  notify = var.review_request_delegation.notify

  review_request_delegation {
    algorithm    = var.review_request_delegation.algorithm
    member_count = var.review_request_delegation.member_count
  }
}

##-----------------------------------------------------------------------------
## IdP group mapping. Requires SAML or SCIM on the organization.
##-----------------------------------------------------------------------------
resource "github_team_sync_group_mapping" "this" {
  count = var.enabled && length(var.sync_group_mapping) > 0 ? 1 : 0

  team_slug = github_team.this[0].slug

  dynamic "group" {
    for_each = var.sync_group_mapping
    content {
      group_id          = group.value.group_id
      group_name        = group.value.group_name
      group_description = group.value.group_description
    }
  }
}
