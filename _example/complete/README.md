# Complete example

Every submodule in this repository, wired into one configuration.

| Module | What it does here |
| --- | --- |
| `modules/organization` | Organization profile, base member permission, security defaults for new repositories, one custom property |
| `modules/team` | The `platform-prod` team, its membership, its grant on the repository, and round robin review delegation |
| `modules/secrets-source-aws` | Reads `STRIPE_KEY` from Secrets Manager and `DD_API_KEY` from SSM Parameter Store |
| `modules/secrets-source-azure` | Reads `AZ_CLIENT_SECRET` from Key Vault |
| root (`modules/repository`, `modules/ruleset`, `modules/environment`, `modules/secrets`) | The repository, its branch ruleset, a `staging` and a `prod` environment, and every secret above |
| `modules/webhook` | Deployment webhook on the repository |
| `modules/actions` | Actions permissions, a private self-hosted runner group, and OIDC subject claim templates |

## Notes on the wiring

The repository, ruleset, environments, and secrets come from one call to the
baseline composite root rather than four separate submodule calls. The root
already sequences them: the ruleset and the environments take the repository
name from the repository submodule, and the secrets submodule takes both the
repository and the environment targets. Calling the four submodules directly
works too, and is what you want when a repository already exists and only its
ruleset is managed here.

`modules/actions` sets `repository_oidc_claim_keys`, which is the alternative
to storing cloud credentials as GitHub secrets. Prefer it. The two source
submodules exist for credentials that genuinely cannot be federated, such as a
third party API key held in Secrets Manager.

The `staging` environment uses `custom_branch_policies` so it can accept
`release/*` branches. The `prod` environment uses `protected_branches` and a 15
minute wait timer. The two flags are mutually exclusive and the environment
submodule enforces that.

## Read this before you apply

Secret values published through this example are written to Terraform state in
clear text. See `_example/secrets-sync/README.md` for what that means and what
to do about it.

## Usage

```bash
export GITHUB_TOKEN=...
terraform init
terraform plan
terraform apply
```

The token needs organization owner scope, because this example manages
organization settings, membership, and Actions policy. AWS and Azure
credentials come from the ambient provider configuration and are used for read
only data sources.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
