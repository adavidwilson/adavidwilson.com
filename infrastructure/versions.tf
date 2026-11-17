terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }

  cloud {
    organization = "adavidwilson-org"
    workspaces {
      name = "adavidwilson-com"
    }
  }
}
