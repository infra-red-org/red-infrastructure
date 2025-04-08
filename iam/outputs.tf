output "workload_identity_sa_email" {
  description = "Email address of the Workload Identity service account"
  value       = google_service_account.workload_identity_sa.email
}

output "workload_identity_sa_name" {
  description = "Fully qualified name of the Workload Identity service account"
  value       = google_service_account.workload_identity_sa.name
}

output "workload_identity_sa_id" {
  description = "Unique ID of the Workload Identity service account"
  value       = google_service_account.workload_identity_sa.unique_id
}

output "workload_identity_sa_member" {
  description = "Member string for the Workload Identity service account"
  value       = "serviceAccount:${google_service_account.workload_identity_sa.email}"
}
