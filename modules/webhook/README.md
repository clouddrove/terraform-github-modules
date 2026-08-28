# webhook

Manages GitHub webhooks at either repository or organization scope.

## Security notes

Webhook `secret` values are written to Terraform state in clear text. Terraform
marks the attribute sensitive so it is redacted in CLI output, but the state
file itself holds the plaintext value. Encrypted remote state is required for
any use of this module that sets a webhook secret. Restrict read access to the
state backend to the same set of people you would trust with the secret itself.

Two rules are enforced by variable validation and are not configurable:

1. Every webhook URL must start with `https://`. Payloads carry repository
   contents and the delivery signature, so plaintext transport is rejected.
2. `insecure_ssl` must stay `false`. Setting it disables TLS certificate
   verification on webhook delivery, which defeats the point of using https.
   Fix the endpoint certificate instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.13.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | 6.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_organization_webhook.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/organization_webhook) | resource |
| [github_repository_webhook.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Flag to control the resources creation. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`environment`. | `list(any)` | <pre>[<br/>  "name",<br/>  "environment"<br/>]</pre> | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'clouddrove' or 'hello@clouddrove.com'. | `string` | `"hello@clouddrove.com"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository the webhooks belong to. Required when scope is repository. | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Webhook scope. One of repository, organization. | `string` | `"repository"` | no |
| <a name="input_webhooks"></a> [webhooks](#input\_webhooks) | Webhooks keyed by an arbitrary label. The `secret` value is stored in<br/>Terraform state in clear text; use encrypted remote state. | <pre>map(object({<br/>    url          = string<br/>    events       = list(string)<br/>    content_type = optional(string, "json")<br/>    secret       = optional(string)<br/>    insecure_ssl = optional(bool, false)<br/>    active       = optional(bool, true)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Composed name for this module instance. |
| <a name="output_webhook_ids"></a> [webhook\_ids](#output\_webhook\_ids) | IDs of the created webhooks, keyed by label. |
| <a name="output_webhook_urls"></a> [webhook\_urls](#output\_webhook\_urls) | Configured webhook URLs, keyed by label. Sensitive because URLs can embed tokens. |
<!-- END_TF_DOCS -->
