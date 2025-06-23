# GKE Module Documentation

## Overview

The GKE (Google Kubernetes Engine) module provisions and configures an Autopilot Kubernetes cluster in Google Cloud Platform. This module creates a fully managed Kubernetes environment with secure networking and identity configurations.

## Components

### Google Kubernetes Engine Autopilot Cluster

The module provisions a GKE Autopilot cluster with the following configurations:

- **Name**: Defined by the `cluster_name` variable
- **Location**: Regional deployment as specified by the `region` variable
- **Mode**: Autopilot (fully managed nodes)
- **Networking**: Custom VPC and subnet integration
- **IP Allocation**: Secondary IP ranges for pods and services
- **Release Channel**: Regular (balanced between stability and new features)
- **Workload Identity**: Enabled for secure authentication to Google Cloud services

## Process Flow

1. **Cluster Creation**:

   - The `google_container_cluster` resource creates the GKE cluster.
   - Autopilot mode is enabled, which means Google manages the node pools automatically.
   - The cluster is deployed in the specified region for high availability.
2. **Network Configuration**:

   - The cluster is integrated with the specified VPC network and subnet.
   - This allows for network isolation and control over traffic.
   - The cluster uses the network and subnetwork provided as variables.
3. **IP Allocation Policy**:

   - Secondary IP ranges are configured for pods and services.
   - The pod range is named "pod-ranges" and uses the CIDR specified in `cluster_ipv4_cidr_block`.
   - The service range is named "service-ranges" and uses the CIDR specified in `services_ipv4_cidr_block`.
4. **Release Channel Configuration**:

   - The cluster is set to the "REGULAR" release channel.
   - This provides a balance between stability and access to new features.
   - Google manages the Kubernetes version and upgrades automatically.
5. **Workload Identity Configuration**:

   - Workload Identity is enabled to allow Kubernetes service accounts to act as Google Cloud service accounts.
   - The workload pool is set to `${var.project_id}.svc.id.goog`.
   - This enables secure authentication without managing service account keys.

## Variables

| Name                     | Description                                      | Type   | Default         | Required |
| ------------------------ | ------------------------------------------------ | ------ | --------------- | :------: |
| project_id               | The project ID where the cluster will be created | string | n/a             |   yes   |
| region                   | The region where the cluster will be created     | string | n/a             |   yes   |
| cluster_name             | The name of the cluster                          | string | n/a             |   yes   |
| network                  | The VPC network to host the cluster              | string | n/a             |   yes   |
| subnetwork               | The subnetwork to host the cluster               | string | n/a             |   yes   |
| cluster_ipv4_cidr_block  | The IP address range for pods in the cluster     | string | "10.100.0.0/14" |    no    |
| services_ipv4_cidr_block | The IP address range for services in the cluster | string | "10.104.0.0/20" |    no    |

## Outputs

| Name             | Description                               |
| ---------------- | ----------------------------------------- |
| cluster_name     | The name of the cluster                   |
| cluster_endpoint | The endpoint for the cluster's API server |
| cluster_id       | The unique identifier of the cluster      |

## Usage

The GKE module is typically used in conjunction with the network and IAM modules:

```hcl
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
```

## Accessing the Cluster

After the cluster is created, you can access it using the gcloud command:

```bash
gcloud container clusters get-credentials [CLUSTER_NAME] --region [REGION] --project [PROJECT_ID]
```

This will configure kubectl to use your new cluster.

## Security Considerations

- The cluster uses Workload Identity for secure authentication to Google Cloud services
- Autopilot mode ensures nodes are automatically patched and updated
- Network policy can be enabled for pod-to-pod traffic control
- Consider enabling Binary Authorization for additional security
- Regular release channel ensures timely security updates

## Best Practices

- Use Workload Identity for authentication instead of service account keys
- Implement network policies to control pod-to-pod communication
- Use namespaces to organize and isolate workloads
- Regularly review cluster security and compliance
- Monitor cluster usage and costs
