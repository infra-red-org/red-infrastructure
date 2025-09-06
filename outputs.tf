output "cluster_name" {
  description = "The name of the created cluster"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the cluster's API server"
  value       = module.gke.cluster_endpoint
}

output "cluster_id" {
  description = "The unique identifier of the cluster"
  value       = module.gke.cluster_id
}

output "keda_status" {
  description = "Status of KEDA installation"
  value       = module.keda.helm_status
}

output "keda_service_account" {
  description = "Email of the service account used by KEDA"
  value       = module.keda.service_account_email
}

# Traefik LoadBalancer IP
output "traefik_ip" {
  description = "External IP address of the Traefik LoadBalancer"
  value       = module.traefik.loadbalancer_ip
}

# DNS Records Instructions
output "dns_records_needed" {
  description = "DNS A records to create in Route53"
  value = {
    prometheus = "${var.prometheus_domain} A ${module.traefik.loadbalancer_ip}"
    grafana    = "${var.grafana_domain} A ${module.traefik.loadbalancer_ip}"
    traefik    = "${var.traefik_domain} A ${module.traefik.loadbalancer_ip}"
  }
}

# Service URLs (after DNS is configured)
output "service_urls" {
  description = "URLs to access services after DNS configuration"
  value = {
    prometheus = "https://${var.prometheus_domain}"
    grafana    = "https://${var.grafana_domain}"
    traefik    = "https://${var.traefik_domain}"
  }
}