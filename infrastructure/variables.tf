variable "account_id" {
  description = "Cloudflare account ID that owns the Worker. Set as an HCP workspace variable."
  type        = string
}

variable "zone_name" {
  description = "DNS zone that already hosts the site in Cloudflare (looked up read-only)."
  type        = string
  default     = "adavidwilson.com"
}

variable "worker_name" {
  description = "Name of the Workers Worker that serves the site."
  type        = string
  default     = "adavidwilson-site"
}

variable "compatibility_date" {
  description = "Workers compatibility date. A new date replaces the version; bump it when adding new features."
  type        = string
  default     = "2025-01-01"
}
