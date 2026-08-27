# Contributing

Thank you for your interest in contributing to this Terraform module!

## Development Setup

1. Install required tools:
   - [Terraform](https://www.terraform.io/downloads) >= 1.10.0
   - [TFLint](https://github.com/terraform-linters/tflint)
   - [terraform-docs](https://terraform-docs.io/)
   - [tfsec](https://aquasecurity.github.io/tfsec/)
   - [checkov](https://www.checkov.io/)
   - [gitleaks](https://github.com/gitleaks/gitleaks)

2. Clone the repository:
   ```bash
   git clone git@github.com:clouddrove/terraform-github-modules.git
   cd terraform-github-modules
   ```

3. Run validation:
   ```bash
   make validate
   make security
   make docs
   ```

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes following the style guide
3. Run all validations locally
4. Update documentation if needed
5. Submit a pull request

## Style Guide

This project follows the [HashiCorp Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style):

- Use `terraform fmt` for formatting
- All variables must have `type` and `description`
- All outputs must have `description`
- Use lowercase with underscores for naming
- Prefer `for_each` over `count` for multiple resources

## Testing

Before submitting:

```bash
# Format check
terraform fmt -check -recursive

# Validate
terraform init -backend=false
terraform validate

# Module tests
make test

# Security scan
make security

# Update docs
make docs
```

`README.md` is generated. Never hand-edit it. Edit `README.yaml` and run `make docs`.

## License

By contributing, you agree that your contributions will be licensed under the Apache-2.0 License.
