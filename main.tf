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
  source                     = "./iam"
  project_id                 = var.project_id
  github_repositories        = var.github_repositories
  workload_identity_pool_id  = var.workload_identity_pool_id
  service_account_id         = var.service_account_id
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
  source                         = "./keda"
  project_id                     = var.project_id
  existing_service_account_email = module.iam.workload_identity_sa_email # Use the existing workload identity service account
  depends_on = [
    module.gke
  ]
}

module "kube_prometheus_stack" {
  source            = "./kube-prometheus-stack"
  namespace         = "monitoring"
  create_namespace  = true
  prometheus_domain = var.prometheus_domain
  grafana_domain    = var.grafana_domain
  depends_on        = [module.gke]
}

module "traefik" {
  source            = "./traefik"
  namespace         = "traefik-v2"
  create_namespace  = true
  chart_version     = "36.3.0"
  letsencrypt_email = var.letsencrypt_email
  traefik_domain    = var.traefik_domain
  depends_on        = [module.gke]
}


