output "secret_names" {
  description = "Names of every secret published by this example."
  value       = module.github_secrets.secret_names
}

output "variable_names" {
  description = "Names of every GitHub Actions variable published by this example."
  value       = module.github_secrets.variable_names
}
