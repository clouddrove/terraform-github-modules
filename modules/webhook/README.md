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
<!-- END_TF_DOCS -->
