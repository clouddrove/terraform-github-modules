# Basic example

Creates one private repository named `api-prod` from the baseline composite
root, applies a branch ruleset to the default branch, and stops there. No
secrets, no environments.

The ruleset blocks branch deletion and force pushes, and requires two approving
reviews on every pull request.

## Usage

```bash
export GITHUB_TOKEN=...
terraform init
terraform plan
terraform apply
```

Set `owner` in the `provider "github"` block to your own organization before
running this.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
