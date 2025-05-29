# Network Module Documentation

## Overview

The Network module provisions the core networking infrastructure required for the GKE cluster. It creates a custom Virtual Private Cloud (VPC) network with a subnet that includes secondary IP ranges for Kubernetes pods and services.

## Components

### VPC Network

The module creates a custom mode VPC network:

- **Name**: Defined by the `vpc_name` variable
- **Auto-create Subnetworks**: Disabled (set to `false`) to allow for custom subnet configuration

### Subnet

The module creates a subnet within the VPC:

- **Name**: Defined by the `subnet_name` variable
- **Region**: Specified by the `region` variable
- **Primary IP Range**: Defined by the `subnet_cidr` variable
- **Private Google Access**: Enabled to allow private instances to access Google APIs
- **Secondary IP Ranges**:
  - **Pod Range**: Named "pod-ranges", CIDR defined by `pod_cidr` variable
  - **Service Range**: Named "service-ranges", CIDR defined by `service_cidr` variable

### Cloud Router and NAT (Currently Disabled)

The module includes commented-out configurations for Cloud Router and Cloud NAT:

- **Router Name**: `${var.vpc_name}-router`
- **NAT Name**: `${var.vpc_name}-nat`
- **NAT Configuration**: Automatic IP allocation for all subnets and IP ranges

## Process Flow

1. **VPC Creation**:

   - The `google_compute_network` resource creates a custom VPC network.
   - Auto-create subnetworks is disabled to allow for custom subnet configuration.
2. **Subnet Creation**:

   - The `google_compute_subnetwork` resource creates a subnet within the VPC.
   - Private Google Access is enabled for secure API access.
   - Secondary IP ranges are configured for Kubernetes pods and services.
3. **Cloud Router and NAT (Currently Disabled)**:

   - These resources are currently commented out in the configuration.
   - When enabled, they would provide outbound internet access for private instances.

## Variables

| Name         | Description                   | Type   | Default | Required |
| ------------ | ----------------------------- | ------ | ------- | :------: |
| project_id   | The project ID                | string | n/a     |   yes   |
| region       | The region for the subnet     | string | n/a     |   yes   |
| vpc_name     | The name of the VPC           | string | n/a     |   yes   |
| subnet_name  | The name of the subnet        | string | n/a     |   yes   |
| subnet_cidr  | The CIDR range for the subnet | string | n/a     |   yes   |
| pod_cidr     | The CIDR range for pods       | string | n/a     |   yes   |
| service_cidr | The CIDR range for services   | string | n/a     |   yes   |

## Outputs

| Name         | Description            |
| ------------ | ---------------------- |
| network_name | The name of the VPC    |
| network_id   | The ID of the VPC      |
| subnet_name  | The name of the subnet |
| subnet_id    | The ID of the subnet   |

**Note**: Outputs for router_name and nat_name are commented out, consistent with the commented-out resources.

## Usage

The Network module is typically used as a foundation for the GKE module:

```hcl
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
```

## Network Connectivity

### Current Configuration

The current configuration creates a private network with:

- Private Google Access enabled (allows access to Google APIs without public IPs)
- No direct internet access for instances in the subnet (NAT is commented out)
- No firewall rules defined (default deny all ingress, allow all egress applies)

### Enabling Internet Access

To enable outbound internet access for instances in the subnet, uncomment the Cloud Router and NAT resources:

```hcl
resource "google_compute_router" "cdsci-router" {
  name    = "${var.vpc_name}-router"
  region  = var.region
  network = google_compute_network.cdsci-vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.vpc_name}-nat"
  router                            = google_compute_router.cdsci-router.name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"  
}
```

Also uncomment the corresponding outputs in `outputs.tf`.

## Security Considerations

- Private Google Access is enabled, allowing secure access to Google APIs
- Consider adding firewall rules to control traffic flow
- Consider enabling Cloud NAT for outbound internet access if needed
- For production environments, consider implementing more granular network segmentation
