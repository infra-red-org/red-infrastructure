resource "google_container_cluster" "cdsci-cluster" {
  name     = var.cluster_name
  location = var.region
  
  # Enable Autopilot
  enable_autopilot = true

  # For Autopilot clusters, we need to specify network config
  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "service-ranges"
  }

  # Recommended settings for Autopilot
  release_channel {
    channel = "REGULAR"
  }
    deletion_protection = false  

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}
