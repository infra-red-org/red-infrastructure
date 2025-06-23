module "network" {
  source = "./network"

  project_id   = var.project_id
  region       = var.region
  vpc_name     = var.vpc_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  pod_cidr     = var.pod_cidr
  service_cidr = var.service_cidr
}

module "iam" {
  source = "./iam"
  project_id    = var.project_id
}

module "gke" {
  source                   = "./gke"
  project_id               = var.project_id
  region                   = var.region
  cluster_name             = var.cluster_name
  network                  = module.network.network_name
  subnetwork               = module.network.subnet_name
  cluster_ipv4_cidr_block  = var.pod_cidr
  services_ipv4_cidr_block = var.service_cidr
  depends_on               = [module.network, module.iam]
}

# KEDA module for event-driven autoscaling
module "keda" {
  source = "./keda"
  
  project_id = var.project_id
  
  # Specify the KEDA version explicitly for version control
  chart_version = "2.17"
  
  # Use the existing workload identity service account
  existing_service_account_email = module.iam.workload_identity_sa_email
  
  # Ensure KEDA is installed after the GKE cluster is created
  depends_on = [
    module.gke
  ]
}

