## Terraform state contains these secrets in clear text

The GitHub provider takes secret values through its `plaintext_value`
argument, and Terraform records that argument in state. Marking a value
sensitive hides it from CLI output; it does not encrypt or omit it in the
state file. Anyone who can read the state file can read every secret this
example publishes.

Before running this example:

- Use a remote backend encrypted with a customer-managed key (S3 with a KMS
  CMK, or an AzureRM backend with a CMK).
- Restrict read access on the state object to the pipeline identity.
- Enable versioning and access logging on the state bucket or container.
- Never commit a `.tfvars` file containing secret values.

For cloud provider access specifically, prefer OIDC federation over stored
credentials. See `modules/actions` for the subject claim customization
templates that make it work.

## What this example does

It draws secret material from three places and publishes all of it through one
call to `modules/secrets`:

| Source | Submodule | Secrets |
| --- | --- | --- |
| AWS Secrets Manager and SSM Parameter Store | `modules/secrets-source-aws` | `STRIPE_KEY`, `DD_API_KEY` |
| Azure Key Vault | `modules/secrets-source-azure` | `AZ_CLIENT_SECRET` |
| Another Terraform module in the same run | none, passed directly | `RDS_PASSWORD`, `DB_HOST` |
| Generated in this run | `modules/secrets` | `SERVICE_TOKEN` |

`DB_HOST` is published as a GitHub Actions variable rather than a secret, so it
is readable in workflow logs. `SERVICE_TOKEN` is generated with a 90 day
rotation window, which means the value changes on the first apply after the
window elapses.

Each secret lands in three scopes: the `api` and `worker` repositories, the
organization with `selected` visibility limited to `api`, and the `prod`
environment on `api`. Dependabot copies are written alongside the Actions
copies because `kinds` asks for both. GitHub has no environment scope for
Dependabot or Codespaces secrets, so those two kinds are written at repository
and organization scope only.

## Wiring a producer module

`var.rds_master_password` and `var.rds_endpoint` stand in for the outputs of
whatever module creates the database. In a real root module you would drop the
variables and write the module reference directly:

```hcl
RDS_PASSWORD = { value = module.rds.master_password }
DB_HOST      = { value = module.rds.endpoint, as_variable = true }
```

That is the point of the split: `modules/secrets` never needs an AWS or Azure
provider, so a caller who only pushes values produced elsewhere configures
nothing but GitHub.

## Usage

```bash
export GITHUB_TOKEN=...
terraform init
terraform plan
terraform apply
```

The AWS and Azure credentials come from the ambient provider configuration.
The `secrets-source-aws` and `secrets-source-azure` submodules read data
sources only; they never create or modify anything in either cloud.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
