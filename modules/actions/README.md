# modules/actions

GitHub Actions administration: organization and repository Actions permissions,
self-hosted runner groups, private repository workflow access level, and OIDC
subject claim customization templates.

## Prefer OIDC over stored cloud credentials

For cloud access specifically, OIDC subject claim customization is the stronger
option. A workflow exchanges a short lived GitHub OIDC token for AWS or Azure
credentials at run time, so no long lived access key ever exists as a GitHub
secret to leak, rotate, or audit.

Set `repository_oidc_claim_keys` (or `organization_oidc_claim_keys`) to shape
the `sub` claim your cloud trust policy matches on, for example
`["repo", "context", "job_workflow_ref"]`. Then scope the AWS IAM role trust
policy or the Azure federated identity credential to that subject.

Use [`modules/secrets`](../secrets) for the values OIDC cannot cover: third
party API tokens, registry passwords, and anything that is not an AWS or Azure
credential. Reach for it for cloud access only when OIDC federation is not
available in your setup.

## Usage

```hcl
module "actions" {
  source = "clouddrove/github-modules/github//modules/actions"

  name        = "api"
  environment = "prod"
  repository  = "api"

  repository_oidc_claim_keys = ["repo", "context", "job_workflow_ref"]

  runner_groups = {
    "self-hosted-prod" = {
      visibility              = "selected"
      selected_repository_ids = [1, 2]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
