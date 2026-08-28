# Terragrunt example

The baseline composite root driven by Terragrunt instead of a Terraform root
module. `terraform.source` points at the repository root; `inputs` supplies the
same variables the `_example/basic` example passes in HCL.

There is no `terraform.tf` here. The provider configuration comes from the
parent Terragrunt configuration in a real setup, usually through a
`generate "provider"` block on a stack level `terragrunt.hcl`:

```hcl
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<-HCL
    provider "github" {
      owner = "clouddrove"
    }
  HCL
}
```

## Usage

```bash
export GITHUB_TOKEN=...
terragrunt init
terragrunt plan
terragrunt apply
```

`make terragrunt-validate` runs `terragrunt validate` in this directory. It
needs the `terragrunt` binary on PATH; the target is skipped when Terragrunt is
not installed.
