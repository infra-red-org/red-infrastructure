provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "cdsci-test" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}
