# --- Existing zone (read-only) ----------------------------------------------
# The zone must already exist in Cloudflare (registrar-created). We only look
# it up; we do not manage zone creation or its nameservers.
data "cloudflare_zone" "site" {
  filter = {
    name = var.zone_name
  }
}

# --- Worker -----------------------------------------------------------------
# Tracks the Worker's existence so versions/deployments can be uploaded
# separately from the Worker itself.
resource "cloudflare_worker" "site" {
  account_id = var.account_id
  name       = var.worker_name
}

# --- Version (static assets only) -------------------------------------------
# A version that carries ONLY static assets (no Worker script). Zola's
# generated site lives in `generated/public` (staged by CI). Changing the
# assets directory changes the manifest hash, which replaces this version.
resource "cloudflare_worker_version" "site" {
  account_id         = var.account_id
  worker_id          = cloudflare_worker.site.id
  compatibility_date = var.compatibility_date

  assets = {
    directory = "generated/public"

    config = {
      # Serve the Zola-generated 404.html for unknown paths.
      not_found_handling = "404-page"
      # Add a trailing slash to HTML pages (matches Zola permalinks).
      html_handling = "auto-trailing-slash"
    }
  }
}

# --- Deployment -------------------------------------------------------------
# Routes traffic to the latest version.
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

# --- Route ------------------------------------------------------------------
# Serves the apex domain over the Worker. For a Cloudflare-hosted zone the
# route alone serves the domain — do NOT also add a `cloudflare_dns_record`
# for the apex (that would be duplicate ownership of the domain).
resource "cloudflare_workers_route" "site" {
  zone_id = data.cloudflare_zone.site.id
  pattern = "${var.custom_domain}/*"
  script  = cloudflare_worker.site.name
  depends_on = [
    cloudflare_worker.site
  ]
}
