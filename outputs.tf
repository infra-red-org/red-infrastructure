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
