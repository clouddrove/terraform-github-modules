# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

First release. The date is set when the `1.0.0` tag is cut.

### Added

- `modules/secrets`: publish secrets and GitHub Actions variables at
  repository, organization, and environment scope, across the `actions`,
  `dependabot`, and `codespaces` kinds. Values are either passed in literally
  or generated in-module with `random_password`, with an optional rotation
  window driven by `time_rotating`. GitHub has no environment scope for
  Dependabot or Codespaces secrets, so those two kinds are written at
  repository and organization scope only. `as_variable = true` publishes an
  Actions variable instead of a secret and is rejected in combination with
  `generate`, because variables are not encrypted.
- `modules/secrets-source-aws`: read values from AWS Secrets Manager and SSM
  Parameter Store. Data sources only, `aws >= 5.0`. `json_key` plucks a single
  field from a JSON Secrets Manager secret.
- `modules/secrets-source-azure`: read values from Azure Key Vault. Data
  sources only, `azurerm >= 4.0`.
- `modules/repository`: repository settings, topics, files, issue labels,
  collaborators, deploy keys, autolink references, branches and default
  branch, custom property values, Dependabot security updates, and GitHub App
  installations.
- `modules/ruleset`: repository and organization rulesets, plus legacy branch
  protection for cases rulesets do not cover.
- `modules/team`: teams, authoritative membership, repository grants,
  automatic review request delegation, and IdP group mapping.
- `modules/organization`: organization profile and security defaults for new
  repositories, membership, blocked users, custom repository roles, and custom
  properties.
- `modules/environment`: deployment environments with wait timers, required
  reviewers, and deployment branch policies. Emits `secrets_target` in the
  shape `modules/secrets` expects in `targets.environments`.
- `modules/actions`: organization and repository Actions permissions,
  self-hosted runner groups, private repository workflow access level, and
  OIDC subject claim customization templates.
- `modules/webhook`: repository and organization webhooks, with `https://`
  URLs and `insecure_ssl = false` enforced by variable validation.
- Baseline composite root wiring `repository`, `ruleset`, `environment`, and
  `secrets` together in dependency order, plus map-driven `wrappers/` that
  call the root once per entry.
- `_example/basic`, `_example/complete`, `_example/secrets-sync`, and
  `_example/terragrunt`.
- `docs/architecture.md` and `docs/io.md`.
- Native `terraform test` suites with `mock_provider` in every submodule and
  at the repository root. No test requires a real GitHub token, AWS account,
  or Azure subscription.

### Notes on provider deprecations

Written against `integrations/github` 6.13.0. The following deprecated
arguments and resources are deliberately avoided.

- `value` is used instead of `plaintext_value` on `github_actions_secret`,
  `github_actions_organization_secret`, `github_actions_environment_secret`,
  `github_dependabot_secret`, and `github_dependabot_organization_secret`. On
  those five resources both `plaintext_value` and `encrypted_value` are
  deprecated. `github_codespaces_secret` and
  `github_codespaces_organization_secret` still use `plaintext_value`, which
  is not deprecated there because they have no `value` attribute.
- `team_slug` is used instead of the deprecated `team_id` on
  `github_team_members`. `github_team_settings` still requires `team_id`.
- `notify` is set at the top level of `github_team_settings` rather than
  inside the `review_request_delegation` block, where it is deprecated.
- `github_organization_repository_role` is used for custom organization
  repository roles, replacing the deprecated custom role resource.
- `github_repository_vulnerability_alerts` is used instead of the deprecated
  `vulnerability_alerts` argument on `github_repository`.
- `github_repository_topics` is used instead of the `topics` argument on
  `github_repository`, so that only one resource writes that GitHub field.

One deprecation is accepted rather than avoided:
`create_default_maintainer` is still set on `github_team`. Omitting it risks
GitHub adding the team creator as a maintainer behind Terraform's back, which
shows up later as silent membership drift. A plan-time deprecation warning is
the cheaper of the two outcomes.

### Security

- Secret values published by `modules/secrets`, and webhook `secret` values in
  `modules/webhook`, are recorded in Terraform state in clear text. Marking a
  value sensitive hides it from CLI output; it does not encrypt or omit it in
  the state file. Remote state encrypted with a customer-managed key, with
  restricted read access, versioning, and access logging, is required. See
  `modules/secrets/README.md`.
- For cloud provider access, OIDC federation through `modules/actions` is the
  documented alternative to storing long lived credentials as GitHub secrets.

[Unreleased]: https://github.com/clouddrove/terraform-github-modules/compare/HEAD
