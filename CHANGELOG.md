# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-08-28

Initial release. Version 0.0.x signals that the module interfaces are not yet
frozen: inputs and outputs may change without a major bump until 1.0.0. Pin an
exact version.

### Added

- `modules/secrets`: publish secrets and GitHub Actions variables at repository,
  organization, and environment scope, across the `actions`, `dependabot`, and
  `codespaces` kinds. Values are passed in literally, resolved by a source
  submodule, or generated in-module with `random_password` and an optional
  rotation window driven by `time_rotating`. GitHub has no environment scope for
  Dependabot or Codespaces secrets, so those kinds are written at repository and
  organization scope only. `as_variable = true` publishes an Actions variable
  instead of a secret and is rejected in combination with `generate`.
- `modules/secrets-source-aws`: read values from AWS Secrets Manager and SSM
  Parameter Store, with `json_key` to pluck a single field.
- `modules/secrets-source-azure`: read values from Azure Key Vault.
  The two source submodules are separate so the `aws` and `azurerm` providers
  stay opt-in for consumers that only push literal values.
- `modules/repository`, `modules/ruleset`, `modules/team`,
  `modules/organization`, `modules/environment`, `modules/actions`,
  `modules/webhook`.
- Baseline composite root module and map-driven `wrappers/`.
- 57 tests running against `mock_provider`, so the suite verifies with no GitHub
  token, AWS account, or Azure subscription.
- CloudDrove standard tooling: geine-generated README, the org workflow set,
  commitlint, semantic-release config, DeepSource, pre-commit, tflint, checkov,
  tfsec, and gitleaks.

### Security

- Secret values are recorded in Terraform state in clear text. This is inherent
  to the GitHub provider API and no module can change it. Use remote state
  encrypted with a customer-managed key, restrict read access, and never commit
  a tfvars file containing secrets. For cloud access prefer OIDC federation; see
  `modules/actions`.
- No resource in `modules/secrets` derives a `for_each` from `var.secrets`.
  Callers merge sensitive maps into it and Terraform rejects a `for_each`
  derived from a sensitive value. Enforced by `tests/sensitive_source.tftest.hcl`.
- Deprecated provider arguments are avoided: `value` over `plaintext_value`,
  `team_slug` on `github_team_members`, top-level `notify` on
  `github_team_settings`, `github_organization_repository_role`, and
  `github_repository_vulnerability_alerts`.
- `branch_protection` defaults require signed commits and two approving reviews.
- Every workflow declares least-privilege `permissions`.
