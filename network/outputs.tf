output "network_name" {
  description = "The name of the VPC"
  value       = google_compute_network.cdsci-vpc.name
}

output "network_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.cdsci-vpc.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

# output "router_name" {
#   description = "The name of the cloud router"
#   value       = google_compute_router.router.name
# }

# output "nat_name" {
#   description = "The name of the cloud NAT"
#   value       = google_compute_router_nat.nat.name
# }