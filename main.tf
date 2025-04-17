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

