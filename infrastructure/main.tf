data "cloudflare_zone" "site" {
  filter = {
    name = var.zone_name
  }
}

resource "cloudflare_worker" "site" {
  account_id = var.account_id
  name       = var.worker_name
}

resource "cloudflare_worker_version" "site" {
  account_id         = var.account_id
  worker_id          = cloudflare_worker.site.id
  compatibility_date = var.compatibility_date

  assets = {
    directory = "generated/public"

    config = {
      not_found_handling = "404-page"
      html_handling = "auto-trailing-slash"
    }
  }
}

resource "cloudflare_workers_deployment" "site" {
  account_id  = var.account_id
  script_name = cloudflare_worker.site.name
  strategy    = "percentage"

  versions = [
    {
      version_id = cloudflare_worker_version.site.id
      percentage = 100
    }
  ]
}

resource "cloudflare_workers_custom_domain" "site" {
  account_id = var.account_id
  hostname = data.cloudflare_zone.site.name
  service = cloudflare_worker.site.name
}

