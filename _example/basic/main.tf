module "github" {
  source = "../../"

  name        = "api"
  environment = "prod"
  description = "API service"
  visibility  = "private"
  topics      = ["terraform", "api"]

  ruleset = {
    ruleset_name = "main-protection"
    rules = {
      deletion         = true
      non_fast_forward = true
      pull_request = {
        required_approving_review_count = 2
      }
    }
  }
}
