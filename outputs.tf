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
