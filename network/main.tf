resource "google_compute_network" "cdsci-vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.cdsci-vpc.id
  ip_cidr_range = var.subnet_cidr

  private_ip_google_access = true
  
  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = var.pod_cidr
  }

  secondary_ip_range {
    range_name    = "service-ranges"
    ip_cidr_range = var.service_cidr
  }
}
# # The following (for now) is optional and can be commented out if not needed
# resource "google_compute_router" "cdsci-router" {
#   name    = "${var.vpc_name}-router"
#   region  = var.region
#   network = google_compute_network.cdsci-vpc.id
# }

# resource "google_compute_router_nat" "nat" {
#   name                               = "${var.vpc_name}-nat"
#   router                            = google_compute_router.cdsci-router.name
#   region                            = var.region
#   nat_ip_allocate_option            = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"  

# }
