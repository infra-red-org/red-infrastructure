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
