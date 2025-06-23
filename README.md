# Cancer Data Science Infrastructure (CDSCI) - GKE Infrastructure

This repository contains Terraform configurations for provisioning a production-ready Google Kubernetes Engine (GKE) Autopilot infrastructure on Google Cloud Platform.

## Architecture Overview

[CDSCI GKE Infrastructure Architecture](red-infrastructure/Architecture_1.0.png)

This infrastructure implements a secure and scalable GKE environment with:

- Private GKE Autopilot cluster
- Custom VPC network with dedicated subnets
- Workload Identity for secure service account management
- Secondary IP ranges for pods and services

## Repository Structure

```
.
├── cloud_bucket/           # Storage bucket for Terraform state
├── gke/                    # GKE cluster configuration
├── iam/                    # Service accounts and permissions
├── network/                # VPC and subnet configurations
├── .github/workflows/      # CI/CD pipeline configurations
├── main.tf                 # Root module configuration
├── variables.tf            # Root variable declarations
├── outputs.tf              # Root output declarations
└── providers.tf            # Provider configurations
```

## Prerequisites

- Terraform >= 1.0
- Google Cloud SDK
- Service account with appropriate permissions
- Enabled Google Cloud APIs:
  - Container API
  - Compute Engine API
  - IAM API

## Getting Started

1. Clone the repository:

```bash
git clone <repository-url>
```

2. Navigate to the repository:

```bash
cd cancer_data-sci/red-infrastructure
```

3. Create a `terraform.tfvars` file with your specific values:

```hcl
project_id   = "your-project-id"
region       = "your-preferred-region"
cluster_name = "your-cluster-name"
vpc_name     = "your-vpc-name"
subnet_name  = "your-subnet-name"
subnet_cidr  = "10.0.0.0/20"  # Adjust as needed
pod_cidr     = "172.16.0.0/14"  # Adjust as needed
service_cidr = "172.20.0.0/20"  # Adjust as needed
```

> **Note:** The `terraform.tfvars` file is not included in this repository for security reasons. You must create your own with values appropriate for your environment.

4. Initialize Terraform:

```bash
terraform init
```

5. Review the plan:

```bash
terraform plan
```

6. Apply the configuration:

```bash
terraform apply
```

## Module Details

### Cloud Bucket

Manages the Terraform state storage:

- Google Cloud Storage bucket with versioning
- Secure access controls
- State locking capabilities

### Network Module

Creates the VPC network infrastructure including:

- Custom VPC network
- Subnet with private Google access
- Secondary IP ranges for pods and services
- Optional Cloud NAT for outbound connectivity

### IAM Module

Manages identity and access including:

- Workload Identity service account
- Required IAM bindings
- Service account permissions
- Secure authentication without service account keys

### GKE Module

Provisions the GKE cluster with:

- Autopilot mode enabled
- Private cluster configuration
- Workload Identity integration
- Network policy enforcement
- Regular release channel for updates

## Accessing the Cluster

After deployment, configure kubectl:

```bash
gcloud container clusters get-credentials <cluster-name> --region <cluster-region>
```

## CI/CD Integration

This repository includes GitHub Actions workflows for automated deployment:

- Manual trigger via workflow_dispatch
- Secure authentication using Workload Identity Federation
- Variable management through GitHub Secrets
- Complete deployment pipeline with validation and testing

## Security Features

- Private cluster with no public control plane
- Workload Identity for secure authentication
- Network policy enforcement
- Private Google Access for API communication
- Principle of least privilege for IAM roles

## Documentation

Detailed documentation is available in the following files:

- [Cloud Bucket](Documentation/cloud_bucket.md)
- [GKE Module](Documentation/gke.md)
- [IAM Module](Documentation/iam.md)
- [Network Module](Documentation/network.md)
- [Complete System](Documentation/red_infrastructure.md)

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request with a clear description of changes
4. Ensure all tests pass

## Support

For support, please contact the infrastructure team or create an issue in the repository.
