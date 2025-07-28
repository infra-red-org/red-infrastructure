# variables.tf
variable "project_id" {
  description = "The project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "The region for resources"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  type        = string
}

variable "pod_cidr" {
  description = "The CIDR range for pods"
  type        = string
}

variable "service_cidr" {
  description = "The CIDR range for services"
  type        = string
}

# Domain and SSL configuration
variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
  default     = "admin@example.com"
}

variable "prometheus_domain" {
  description = "Domain for Prometheus access"
  type        = string
  default     = "gke-prometheus.example.com"
}

variable "grafana_domain" {
  description = "Domain for Grafana access"
  type        = string
  default     = "gke-grafana.example.com"
}

variable "traefik_domain" {
  description = "Domain for Traefik dashboard"
  type        = string
  default     = "gke-traefik.example.com"
}

variable "github_repositories" {
  description = "List of GitHub repositories in the format 'owner/repo' for Workload Identity Federation"
  type        = list(string)
  default     = ["your-github-username/your-repo-name"]
}

# Workload Identity Configuration (optional overrides)
variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
  default     = "terraform-github-pool"
}

variable "service_account_id" {
  description = "ID for the Workload Identity Service Account"
  type        = string
  default     = "terraform-github-sa"
}