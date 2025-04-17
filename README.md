# Cancer Data Science Infrastructure (CDSCI) - GKE Infrastructure

This repository contains Terraform configurations for provisioning an Auto-Pilot GKE infrastructure on Google Cloud Platform.

## Architecture Overview
[CDSCI GKE Infrastructure Architecture](Architecture_1.0.png)


This infrastructure implements a secure and scalable GKE environment with:
- Private GKE Autopilot cluster
- Custom VPC network with dedicated subnets
- Workload Identity for secure service account management
- Secondary IP ranges for pods and services


## Usage

1. Clone the repository:
```
git clone <repository-url>
```

2. Navigate to the repository:
```
cd cancer_data-sci/red-infrastructure
```

3. Initialize Terraform
```
terraform init
```

4. Review the plan:
```
terraform plan
```

5. Apply the configuration
```
terraform plan
```

# Module Details
### Network Module
Creates the VPC network infrastructure including:

- Custom VPC network

- Subnet with private Google access

- Secondary IP ranges for pods and services

### IAM Module
Manages identity and access including:

- Workload Identity service account

- Required IAM bindings

- Service account permissions

### GKE Module
Provisions the GKE cluster with:

- Autopilot mode enabled

- Private cluster configuration

- Workload Identity integration

- Network policy enforcement


# Contributing

1. Create a feature branch

2. Make your changes

3. Submit a pull request with a clear description of changes

4. Ensure all tests pass

