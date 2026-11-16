output "worker_name" {
  description = "Name of the deployed Worker."
  value       = cloudflare_worker.site.name
}

output "domain" {
  description = "Domain served by the Worker."
  value       = var.custom_domain
}

output "deployment_id" {
  description = "ID of the current deployment."
  value       = cloudflare_workers_deployment.site.id
}
