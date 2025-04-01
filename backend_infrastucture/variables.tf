variable "project_id" {
  type        = string
  description = "The ID of the GCP project"
}

variable "region" {
  type        = string
  description = "The region for the resources"
}

variable "bucket_name" {
  type        = string
  description = "The name of the GCS bucket for terraform state"
}

variable "location" {
  type        = string
  description = "The location for the GCS bucket"
  default     = "US"
}

