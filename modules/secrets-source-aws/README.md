# modules/secrets-source-aws

Reads secret values from AWS Secrets Manager and SSM Parameter Store and emits
them in the shape [`modules/secrets`](../secrets) accepts, so the two compose
with a plain `merge()`.

This module contains data sources only. It never creates or modifies anything
in AWS. The `aws` provider floor is `>= 5.0` and is deliberately not raised to
6.x: a major floor here would force a provider upgrade on every consumer for
no functional gain.

## Why this is a separate module

Terraform configures a provider whenever the graph contains resource nodes
belonging to it, including nodes gated to zero instances. Folding these data
sources into `modules/secrets` behind a `count = 0` flag would therefore still
require every caller to configure and download the AWS provider, even the ones
pushing a literal string. Keeping AWS in its own submodule is what makes it
genuinely opt-in.

## Usage

```hcl
module "aws_source" {
  source = "clouddrove/github-modules/github//modules/secrets-source-aws"

  secrets = {
    STRIPE_KEY = {
      arn      = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:app/stripe"
      json_key = "api_key"
    }
    DD_API_KEY = {
      ssm_parameter = "/prod/datadog/api_key"
    }
  }
}

module "github_secrets" {
  source = "clouddrove/github-modules/github//modules/secrets"

  secrets = module.aws_source.values
  targets = { repositories = ["api"] }
}
```

Set exactly one of `arn` or `ssm_parameter` per entry. `json_key` plucks a
single field out of a JSON Secrets Manager secret and is valid only with
`arn`, because SSM parameters are plain strings.

The `values` output is marked sensitive as a whole map. That is intentional and
`modules/secrets` handles it; see that module's README for why every `for_each`
there iterates key names.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_ssm_parameter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets to read from AWS, keyed by the GitHub secret name they will become.<br/>Set exactly one of `arn` (Secrets Manager) or `ssm_parameter` (SSM Parameter<br/>Store). `json_key` plucks one field from a JSON Secrets Manager secret and is<br/>valid only with `arn`. | <pre>map(object({<br/>    arn           = optional(string)<br/>    ssm_parameter = optional(string)<br/>    json_key      = optional(string)<br/>    version_id    = optional(string)<br/>    version_stage = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_values"></a> [values](#output\_values) | Resolved secret values, shaped for the secrets module's `secrets` input. Merge this into that map. |
<!-- END_TF_DOCS -->
