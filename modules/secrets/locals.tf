locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  # Entries split by destination type.
  secret_entries   = { for k, v in var.secrets : k => v if !v.as_variable }
  variable_entries = { for k, v in var.secrets : k => v if v.as_variable }

  # Effective kinds per entry: the per-secret override, else the module default.
  kinds_for = { for k, v in var.secrets : k => coalesce(v.kinds, var.kinds) }

  # Resolved value per entry: the literal, or the generated password.
  value_for = {
    for k, v in var.secrets : k => v.generate != null ? random_password.this[k].result : v.value
  }

  # Entry names filtered by kind, used to build the target products below.
  names_by_kind = {
    for kind in ["actions", "dependabot", "codespaces"] :
    kind => [for k, v in local.secret_entries : k if contains(local.kinds_for[k], kind)]
  }

  repositories = var.enabled ? var.targets.repositories : []
  environments = var.enabled ? var.targets.environments : []
  org_enabled  = var.enabled && var.targets.organization != null

  # Repository scope: cartesian product of repositories and eligible names.
  # setproduct returns an empty list when either input is empty, so no
  # merge()-on-empty-list guard is needed.
  actions_repo = {
    for pair in setproduct(local.repositories, local.names_by_kind.actions) :
    "${pair[0]}/${pair[1]}" => { repository = pair[0], name = pair[1] }
  }

  dependabot_repo = {
    for pair in setproduct(local.repositories, local.names_by_kind.dependabot) :
    "${pair[0]}/${pair[1]}" => { repository = pair[0], name = pair[1] }
  }

  codespaces_repo = {
    for pair in setproduct(local.repositories, local.names_by_kind.codespaces) :
    "${pair[0]}/${pair[1]}" => { repository = pair[0], name = pair[1] }
  }

  # Organization scope.
  actions_org    = local.org_enabled ? { for n in local.names_by_kind.actions : n => n } : {}
  dependabot_org = local.org_enabled ? { for n in local.names_by_kind.dependabot : n => n } : {}
  codespaces_org = local.org_enabled ? { for n in local.names_by_kind.codespaces : n => n } : {}

  # Environment scope. Actions only; GitHub has no environment-scoped
  # dependabot or codespaces secrets.
  actions_env = {
    for pair in setproduct(local.environments, local.names_by_kind.actions) :
    "${pair[0].repository}/${pair[0].environment}/${pair[1]}" => {
      repository  = pair[0].repository
      environment = pair[0].environment
      name        = pair[1]
    }
  }

  # Variable destinations.
  variable_names = [for k, v in local.variable_entries : k]

  variables_repo = {
    for pair in setproduct(local.repositories, local.variable_names) :
    "${pair[0]}/${pair[1]}" => { repository = pair[0], name = pair[1] }
  }

  variables_org = local.org_enabled ? { for n in local.variable_names : n => n } : {}

  variables_env = {
    for pair in setproduct(local.environments, local.variable_names) :
    "${pair[0].repository}/${pair[0].environment}/${pair[1]}" => {
      repository  = pair[0].repository
      environment = pair[0].environment
      name        = pair[1]
    }
  }
}
