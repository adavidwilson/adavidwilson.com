# --- Cloudflare account (REQUIRED) ------------------------------------------
# Not stored in the repository. Set it as a non-sensitive HCP Terraform
# workspace variable named `account_id` (see README.md).
variable "account_id" {
  description = "Cloudflare account ID that owns the Worker. Set as an HCP workspace variable."
  type        = string
}

# --- Zone / domain (from zola.toml base_url) --------------------------------
variable "zone_name" {
  description = "DNS zone that already hosts the site in Cloudflare (looked up read-only)."
  type        = string
  default     = "adavidwilson.com"
}

variable "custom_domain" {
  description = "Custom domain served by the Worker. A route for this domain is managed below; do not also manage a matching DNS record."
  type        = string
  default     = "adavidwilson.com"
}

# --- Worker identity --------------------------------------------------------
variable "worker_name" {
  description = "Name of the Workers Worker that serves the site."
  type        = string
  default     = "adavidwilson-site"
}

# --- Assets -----------------------------------------------------------------
variable "compatibility_date" {
  description = "Workers compatibility date. A new date replaces the version; bump it when adding new features."
  type        = string
  default     = "2025-01-01"
}
