terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.29.0"
    }
  }

  # --- CLI-driven remote execution on HCP Terraform -------------------------
  #
  # This workspace is a CLI-driven (not VCS-connected) workspace: GitHub
  # Actions runs `terraform plan`/`terraform apply` against it and uploads the
  # working directory (including the generated site files) as the run config.
  #
  # `organization` and `workspaces.name` MUST be literal strings here — they
  # cannot be Terraform variables. Replace the placeholders below with your
  # real HCP values (see README.md, "HCP Terraform setup").
  cloud {
    organization = "adavidwilson-org"
    workspaces {
      name = "adavidwilson-com"
    }
  }
}
