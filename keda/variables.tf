# Required variable for the project ID
variable "project_id" {
  description = "The project ID where resources will be created"
  type        = string
}

# Name for the KEDA Helm release
variable "name" {
  description = "Name for the KEDA installation"
  type        = string
  default     = "keda"
}

# Kubernetes namespace for KEDA installation
variable "namespace" {
  description = "Kubernetes namespace for KEDA"
  type        = string
  default     = "keda"
}

# Version of the KEDA Helm chart to install
variable "chart_version" {
  description = "Version of the KEDA Helm chart"
  type        = string
  default     = "2.17.1"
}

# Email of the existing service account to use
variable "existing_service_account_email" {
  description = "Email of the existing service account to use for KEDA"
  type        = string
}

# Name of the Kubernetes service account used by KEDA operator
variable "k8s_service_account" {
  description = "Name of the Kubernetes service account used by KEDA"
  type        = string
  default     = "keda-operator"
}

# List of IAM roles to assign to the KEDA service account
variable "permissions" {
  description = "List of IAM roles to assign to the KEDA service account"
  type        = list(string)
  default     = [
    "roles/monitoring.viewer",        # For general metrics-based scaling
    "roles/cloudsql.viewer",          # For Cloud SQL database scaling
    "roles/compute.viewer"           # For Compute Engine instance scaling
  ]
}