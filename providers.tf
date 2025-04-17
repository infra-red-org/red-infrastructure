provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  # required_providers {
  #   google = {
  #     source  = "hashicorp/google"
  #     version = "~> 5.0" 
  #   }
  # }
  backend "gcs" {
    bucket = "cdsci-state-store-27-03-25"
    prefix = "terraform/state"
  }
}  