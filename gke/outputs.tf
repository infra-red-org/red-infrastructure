output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.cdsci-cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for the cluster's API server"
  value       = google_container_cluster.cdsci-cluster.endpoint
  sensitive   = true
}

output "cluster_id" {
  description = "The unique identifier of the cluster"
  value       = google_container_cluster.cdsci-cluster.id
}

output "ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  value       = google_container_cluster.cdsci-cluster.master_auth.0.cluster_ca_certificate
  sensitive   = true
}
