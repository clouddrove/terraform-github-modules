.PHONY: fmt validate test docs ci tofu-fmt tofu-validate terragrunt-validate security tflint

MODULES := $(shell find modules -maxdepth 1 -mindepth 1 -type d 2>/dev/null)

fmt:
	terraform fmt -recursive

validate:
	terraform init -backend=false
	terraform validate
	@for m in $(MODULES); do \
		echo "==> validating $$m"; \
		terraform -chdir=$$m init -backend=false >/dev/null && \
		terraform -chdir=$$m validate || exit 1; \
	done

test:
	terraform test
	@for m in $(MODULES); do \
		if [ -d "$$m/tests" ]; then \
			echo "==> testing $$m"; \
			terraform -chdir=$$m init -backend=false >/dev/null && \
			terraform -chdir=$$m test || exit 1; \
		fi; \
	done

tofu-fmt:
	tofu fmt -recursive

tofu-validate:
	tofu init -backend=false
	tofu validate

terragrunt-validate:
	cd _example/terragrunt && terragrunt validate

# --recursive resolves .tflint.hcl relative to each target directory, so the
# root config must be passed explicitly with an absolute path.
tflint:
	@command -v tflint >/dev/null 2>&1 || (echo "tflint is required"; exit 1)
	tflint --init
	tflint --recursive -f compact --config "$(CURDIR)/.tflint.hcl"

security:
	@command -v gitleaks >/dev/null 2>&1 || (echo "gitleaks is required"; exit 1)
	@command -v checkov >/dev/null 2>&1 || (echo "checkov is required"; exit 1)
	gitleaks detect --source . --verbose
	checkov -d . --compact

docs:
	@command -v terraform-docs >/dev/null 2>&1 || (echo "terraform-docs is required"; exit 1)
	terraform-docs markdown table --output-file README.md --output-mode inject .
	@for m in $(MODULES); do \
		terraform-docs markdown table --output-file README.md --output-mode inject $$m; \
	done

ci: fmt validate test
