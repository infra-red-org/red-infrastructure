variable "chart_version" {
  description = "Version of the Traefik Helm chart"
  type        = string
  default     = "36.3.0"
}

variable "namespace" {
  description = "Kubernetes namespace for Traefik"
  type        = string
  default     = "traefik-v2"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
  default     = "user@example.com"
}

variable "traefik_domain" {
  description = "Domain for Traefik dashboard"
  type        = string
  default     = "gke-traefik.example.com"
}