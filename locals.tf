locals {
  ## modules/ruleset validates that `repository` is non-null whenever `scope`
  ## is "repository". Variable validation runs even when the submodule is
  ## disabled, so fall back to var.name while the repository does not exist.
  ruleset_repository = module.repository.repository_name != null ? module.repository.repository_name : var.name

  ## modules/secrets takes plain repository names. Only publish to the
  ## repository this root manages, and only while it exists.
  secret_repositories = var.enabled ? [module.repository.repository_name] : []
}
