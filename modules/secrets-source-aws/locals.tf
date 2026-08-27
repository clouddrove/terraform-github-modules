locals {
  id = join("-", compact([for part in var.label_order : lookup({ name = var.name, environment = var.environment, managedby = var.managedby }, part, "")]))

  from_secretsmanager = {
    for k, v in var.secrets : k => (
      v.json_key != null
      ? jsondecode(data.aws_secretsmanager_secret_version.this[k].secret_string)[v.json_key]
      : data.aws_secretsmanager_secret_version.this[k].secret_string
    )
    if var.enabled && v.arn != null
  }

  from_ssm = {
    for k, v in var.secrets : k => data.aws_ssm_parameter.this[k].value
    if var.enabled && v.ssm_parameter != null
  }

  resolved = merge(local.from_secretsmanager, local.from_ssm)
}
