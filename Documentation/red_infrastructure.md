# Red Infrastructure - Complete System Documentation

## Overview

The Red Infrastructure project provides a comprehensive, modular Terraform configuration for deploying a production-ready Google Kubernetes Engine (GKE) environment with proper networking, IAM, and storage components. This documentation explains how all the modules connect together to create a complete cloud infrastructure.

## Architecture

The infrastructure consists of four main components:

1. **Cloud Bucket**: Google Cloud Storage bucket for Terraform state management
2. **Network Infrastructure**: VPC, subnet, and secondary IP ranges for the GKE cluster
3. **IAM Configuration**: Service accounts and permissions for Workload Identity
4. **GKE Cluster**: Autopilot Kubernetes cluster with proper networking and security

## Module Integration

### Root Configuration

The root `main.tf` file orchestrates the creation of all resources by connecting the modules in the correct order:

```hcl
module "network" {
  source = "./network"
  # Network configuration variables
}

module "iam" {
  source = "./iam"
  project_id = var.project_id
}

module "gke" {
  source = "./gke"
  # GKE configuration variables
  depends_on = [module.network, module.iam]
}
```

This structure ensures that:

1. The network is created first
2. IAM resources are created in parallel
3. The GKE cluster is created only after both network and IAM resources are available

### Data Flow Between Modules

The modules share data through variables and outputs:

1. **Root to Network Module**:

   - Project ID, region, VPC name, subnet name, and CIDR ranges are passed from root variables
2. **Network to GKE Module**:

   - Network name and subnet name are passed from network outputs to GKE inputs
   - Secondary IP ranges are configured to match between network and GKE
3. **IAM to GKE Module**:

   - The GKE module depends on the IAM module for service account creation
   - Workload Identity is configured in both modules to work together
4. **Root Outputs**:

   - Key GKE cluster information is exposed as root outputs for easy access

## Deployment Process

### Variables and Configuration

All configuration is parameterized through variables:

1. **Root Variables**:

   - Defined in `variables.tf`
   - Values provided in `terraform.tfvars`
   - Include project ID, region, cluster name, network names, and CIDR ranges
2. **Current Configuration**:

   - Project: "cdsci-test"
   - Region: "us-central1"
   - Cluster Name: "cdsci-cluster"
   - VPC Name: "cdsci-vpc"
   - Subnet CIDR: "10.0.0.0/20"
   - Pod CIDR: "172.16.0.0/14"
   - Service CIDR: "172.20.0.0/20"

### State Management

Terraform state is stored in a Google Cloud Storage bucket:

```hcl
terraform {
  backend "gcs" {
    bucket = "cdsci-state-store-27-03-25"
    prefix = "terraform/state"
  }
}
```

This bucket is created by the backend infrastructure module and enables:

- Team collaboration
- State locking
- Version history

### CI/CD Integration

The infrastructure is deployed using GitHub Actions:

1. **Workflow Trigger**:

   - Currently configured for manual triggering via `workflow_dispatch`
   - Push trigger to main branch is commented out
2. **Authentication**:

   - Uses Workload Identity Federation for secure authentication
   - No service account keys are stored in GitHub
3. **Variable Management**:

   - Variables are stored as GitHub Secrets
   - A tfvars file is dynamically created during the workflow
4. **Deployment Steps**:

   - Checkout code
   - Setup Terraform
   - Authenticate to Google Cloud
   - Initialize Terraform
   - Format and validate configuration
   - Plan changes
   - Apply changes
   - Destroy resources (currently enabled, likely for testing)

## Component Interactions

### Network and GKE Integration

1. **VPC and Subnet**:

   - GKE cluster is deployed in the custom VPC and subnet
   - Private Google Access is enabled for API communication
2. **Secondary IP Ranges**:

   - Pod range: "172.16.0.0/14" (named "pod-ranges")
   - Service range: "172.20.0.0/20" (named "service-ranges")
   - These ranges are referenced by name in the GKE configuration

### IAM and GKE Integration

1. **Workload Identity**:

   - IAM module creates a service account with necessary permissions
   - GKE module enables Workload Identity with the project's workload pool
   - Kubernetes service accounts can impersonate the GCP service account
2. **Permissions**:

   - Storage Object Viewer: Read access to Cloud Storage
   - BigQuery Admin: Full access to BigQuery resources

## Security Features

1. **Network Security**:

   - Private Google Access enabled
   - Custom VPC for network isolation
   - Secondary IP ranges for pod and service isolation
2. **Identity Security**:

   - Workload Identity for secure authentication
   - No service account keys
   - Principle of least privilege for IAM roles
3. **Cluster Security**:

   - Autopilot mode for automatic security updates
   - Regular release channel for timely updates

## Customization Options

1. **Cloud NAT**:

   - Currently commented out in the network module
   - Can be enabled for outbound internet access
2. **Workload Identity Scope**:

   - Currently configured for default namespace and service account
   - Can be customized for different namespaces and service accounts
3. **Provider Version**:

   - Provider version constraints are commented out
   - Can be uncommented and adjusted as needed

## Limitations and Considerations

1. **Autopilot Limitations**:

   - Limited control over node configurations
   - Some features may not be available
2. **Network Configuration**:

   - No explicit firewall rules defined
   - Cloud NAT is commented out, limiting outbound internet access
3. **CI/CD Configuration**:

   - Currently includes a destroy step, which may not be desired for production
   - Manual trigger only, no automatic deployments

## Best Practices

1. **State Management**:

   - Use remote state with locking
   - Implement state backup
2. **Security**:

   - Follow principle of least privilege
   - Implement network segmentation
   - Enable Cloud NAT only if needed
3. **CI/CD**:

   - Use separate environments for development, staging, and production
   - Implement approval workflows for production changes
   - Remove destroy step for production environments

## Conclusion

The Red Infrastructure project provides a solid foundation for deploying a GKE cluster with proper networking and security configurations. The modular approach allows for easy customization and extension, while the CI/CD integration enables automated deployments.
