output "release_name" {
  description = "Name of the Traefik Helm release"
  value       = helm_release.traefik.name
}

output "namespace" {
  description = "Namespace where Traefik is deployed"
  value       = helm_release.traefik.namespace
}

# Data source to get the LoadBalancer IP
data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = helm_release.traefik.namespace
  }
  depends_on = [helm_release.traefik]
}

output "loadbalancer_ip" {
  description = "External IP address of the Traefik LoadBalancer"
  value       = try(data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip, "pending")
}

