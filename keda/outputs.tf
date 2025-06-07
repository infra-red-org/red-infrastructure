# Email of the Google service account used by KEDA
output "service_account_email" {
  description = "Email of the Google service account used by KEDA"
  value       = var.existing_service_account_email
}

# Status of the KEDA Helm release
output "helm_status" {
  description = "Status of the KEDA Helm release"
  value       = helm_release.keda.status
}

# Namespace where KEDA is installed
output "namespace" {
  description = "Namespace where KEDA is installed"
  value       = var.namespace
}