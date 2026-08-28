terraform {
  required_version = ">= 1.10.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.13.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.14.1"
    }
  }
}

provider "github" {
  owner = "clouddrove"
}
