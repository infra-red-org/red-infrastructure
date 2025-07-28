# iam/variables.tf
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "cluster_sa_id" {
  description = "ID for the cluster service account"
  type        = string
  default     = "gke-cluster-sa"
}

variable "github_repositories" {
  description = "List of GitHub repositories in the format 'owner/repo' for Workload Identity Federation"
  type        = list(string)
  default     = ["your-github-username/your-repo-name"]
}

# Workload Identity Pool Configuration
variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
  default     = "terraform-github-pool"
}

variable "workload_identity_pool_display_name" {
  description = "Display name for the Workload Identity Pool"
  type        = string
  default     = "Terraform GitHub Actions Pool"
}

variable "workload_identity_pool_description" {
  description = "Description for the Workload Identity Pool"
  type        = string
  default     = "Workload Identity Pool for GitHub Actions (managed by Terraform)"
}

# Workload Identity Provider Configuration
variable "workload_identity_provider_id" {
  description = "ID for the Workload Identity Pool Provider"
  type        = string
  default     = "terraform-github-provider"
}

variable "workload_identity_provider_display_name" {
  description = "Display name for the Workload Identity Pool Provider"
  type        = string
  default     = "Terraform GitHub Provider"
}

# Service Account Configuration
variable "service_account_id" {
  description = "ID for the Workload Identity Service Account"
  type        = string
  default     = "terraform-github-sa"
}

variable "service_account_display_name" {
  description = "Display name for the Workload Identity Service Account"
  type        = string
  default     = "terraform-github-sa"
}

variable "service_account_description" {
  description = "Description for the Workload Identity Service Account"
  type        = string
  default     = "Service account for GitHub Actions (managed by Terraform)"
}
