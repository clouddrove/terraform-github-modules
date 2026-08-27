data "aws_secretsmanager_secret_version" "this" {
  for_each = var.enabled ? { for k, v in var.secrets : k => v if v.arn != null } : {}

  secret_id     = each.value.arn
  version_id    = each.value.version_id
  version_stage = each.value.version_stage
}

data "aws_ssm_parameter" "this" {
  for_each = var.enabled ? { for k, v in var.secrets : k => v if v.ssm_parameter != null } : {}

  name            = each.value.ssm_parameter
  with_decryption = true
}
