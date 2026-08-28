##-----------------------------------------------------------------------------
## Organization-wide settings, membership, and custom properties.
##-----------------------------------------------------------------------------
module "organization" {
  source = "../../modules/organization"

  name        = "clouddrove"
  environment = "prod"

  billing_email                          = "billing@clouddrove.com"
  company                                = "CloudDrove"
  blog                                   = "https://clouddrove.com"
  location                               = "Remote"
  organization_description               = "Cloud and DevOps engineering."
  default_repository_permission          = "read"
  members_can_create_repositories        = false
  members_can_create_public_repositories = false
  web_commit_signoff_required            = true

  dependabot_alerts_enabled_for_new_repositories               = true
  secret_scanning_enabled_for_new_repositories                 = true
  secret_scanning_push_protection_enabled_for_new_repositories = true

  members = {
    octocat = "member"
  }

  custom_properties = {
    service_tier = {
      value_type     = "single_select"
      required       = true
      default_value  = "tier-3"
      description    = "Operational tier of the service."
      allowed_values = ["tier-1", "tier-2", "tier-3"]
    }
  }
}

##-----------------------------------------------------------------------------
## The team that owns the repository.
##-----------------------------------------------------------------------------
module "team" {
  source = "../../modules/team"

  name        = "platform"
  environment = "prod"

  description = "Platform engineering."
  privacy     = "closed"

  members = {
    octocat = "maintainer"
  }

  repositories = {
    (module.baseline.repository_name) = "push"
  }

  review_request_delegation = {
    algorithm    = "ROUND_ROBIN"
    member_count = 1
    notify       = true
  }
}

##-----------------------------------------------------------------------------
## Secret material read out of AWS and Azure. Both submodules read data
## sources only; neither creates anything in either cloud.
##-----------------------------------------------------------------------------
module "aws_secrets" {
  source = "../../modules/secrets-source-aws"

  name        = "api"
  environment = "prod"

  secrets = {
    STRIPE_KEY = { arn = "arn:aws:secretsmanager:eu-west-1:1234:secret:app/stripe", json_key = "api_key" }
    DD_API_KEY = { ssm_parameter = "/prod/datadog/api_key" }
  }
}

module "azure_secrets" {
  source = "../../modules/secrets-source-azure"

  name        = "api"
  environment = "prod"

  secrets = {
    AZ_CLIENT_SECRET = { key_vault_id = data.azurerm_key_vault.prod.id, name = "gha-sp" }
  }
}

data "azurerm_key_vault" "prod" {
  name                = "prod-key-vault"
  resource_group_name = "prod-rg"
}

##-----------------------------------------------------------------------------
## Repository, ruleset, environments, and secrets, in one call to the
## baseline composite root.
##-----------------------------------------------------------------------------
module "baseline" {
  source = "../../"

  name        = "api"
  environment = "prod"
  description = "API service"
  visibility  = "private"
  topics      = ["terraform", "api", "clouddrove"]

  vulnerability_alerts = true
  archive_on_destroy   = true

  files = {
    "CODEOWNERS" = { content = "* @clouddrove/platform-prod" }
  }

  issue_labels = {
    bug         = { color = "d73a4a", description = "Something is broken" }
    enhancement = { color = "a2eeef", description = "New feature or request" }
  }

  collaborators = {
    users = { octocat = "push" }
    teams = { platform-prod = "maintain" }
  }

  ruleset = {
    ruleset_name = "main-protection"
    enforcement  = "active"
    conditions = {
      ref_name = {
        include = ["~DEFAULT_BRANCH"]
        exclude = []
      }
    }
    rules = {
      deletion                = true
      non_fast_forward        = true
      required_linear_history = true
      required_signatures     = true
      pull_request = {
        required_approving_review_count = 2
        require_code_owner_review       = true
      }
      required_status_checks = {
        required_check = [
          { context = "terraform" },
          { context = "security" },
        ]
      }
    }
  }

  environments = {
    staging = {
      wait_timer = 0
      deployment_branch_policy = {
        protected_branches     = false
        custom_branch_policies = true
      }
      branch_patterns = ["release/*"]
    }
    prod = {
      wait_timer = 15
      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }
    }
  }

  secret_kinds = ["actions", "dependabot"]

  secrets = merge(
    module.aws_secrets.values,
    module.azure_secrets.values,
    {
      SERVICE_TOKEN = { generate = { length = 40, special = false, rotation_days = 90 } }
      API_BASE_URL  = { value = "https://api.clouddrove.com", as_variable = true }
    }
  )
}

##-----------------------------------------------------------------------------
## Delivery webhook on the repository.
##-----------------------------------------------------------------------------
module "webhook" {
  source = "../../modules/webhook"

  name        = "api"
  environment = "prod"

  scope      = "repository"
  repository = module.baseline.repository_name

  webhooks = {
    deployments = {
      url          = "https://hooks.clouddrove.com/github/deployments"
      events       = ["deployment", "deployment_status"]
      content_type = "json"
    }
  }
}

##-----------------------------------------------------------------------------
## Actions permissions, a self-hosted runner group, and the OIDC subject claim
## template that removes the need for stored cloud credentials.
##-----------------------------------------------------------------------------
module "actions" {
  source = "../../modules/actions"

  name        = "api"
  environment = "prod"

  repository = module.baseline.repository_name

  organization_permissions = {
    allowed_actions      = "selected"
    enabled_repositories = "all"
    allowed_actions_config = {
      github_owned_allowed = true
      verified_allowed     = true
      patterns_allowed     = ["clouddrove/*"]
    }
  }

  repository_permissions = {
    allowed_actions = "selected"
    enabled         = true
    allowed_actions_config = {
      github_owned_allowed = true
      verified_allowed     = true
      patterns_allowed     = ["clouddrove/*"]
    }
  }

  runner_groups = {
    "api-prod-runners" = {
      visibility                 = "private"
      allows_public_repositories = false
      restricted_to_workflows    = true
      selected_workflows         = ["clouddrove/api-prod/.github/workflows/deploy.yml@refs/heads/main"]
    }
  }

  organization_oidc_claim_keys = ["repository_owner", "repository"]
  repository_oidc_claim_keys   = ["repo", "context"]

  repository_access_level = "organization"
}
