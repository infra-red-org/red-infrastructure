variable "chart_version" {
  description = "Version of the Kube Prometheus Stack Helm chart"
  type        = string
  default     = "75.5.0"
}

variable "namespace" {
  description = "Kubernetes namespace for Kube Prometheus Stack"
  type        = string
  default     = "monitoring"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
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