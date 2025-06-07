# KEDA Setup for Cancer Data Science Infrastructure

This document explains how KEDA (Kubernetes Event-driven Autoscaling) is implemented in the Cancer Data Science Infrastructure (CDSCI) project using Terraform.

## What is KEDA?

KEDA is a Kubernetes-based Event Driven Autoscaler that enables fine-grained autoscaling for event-driven workloads. It allows Kubernetes workloads to scale to zero and from zero based on the number of events needing to be processed.

## Implementation Overview

KEDA is implemented as a Terraform module within the project structure. This modular approach allows for:
- Clean separation of concerns
- Reusable configuration
- Centralized management of KEDA settings
- Easy customization through variables

## Directory Structure

```
red-infrastructure/
├── keda/                   # KEDA module
│   ├── main.tf             # Main KEDA resources
│   ├── variables.tf        # Module variables
│   └── outputs.tf          # Module outputs
├── main.tf                 # Root module that calls KEDA module
├── outputs.tf              # Root outputs including KEDA status
└── providers.tf            # Provider configuration for Helm
```

## Step-by-Step Implementation

### 1. Create the KEDA Module Structure

The KEDA module consists of three files:

- `main.tf`: Contains the resources for KEDA installation and IAM configuration
- `variables.tf`: Defines all variables used by the module
- `outputs.tf`: Exposes important values from the module

### 2. Define KEDA Resources (keda/main.tf)

The `main.tf` file contains two main resources:

1. **Helm Release**: Installs KEDA using the Helm chart
2. **IAM Permissions**: Adds necessary permissions to the existing service account

Note: The Workload Identity binding is handled in the IAM module by adding the KEDA operator's Kubernetes service account to the existing binding.

### 3. Configure Variables (keda/variables.tf)

The `variables.tf` file defines all the variables used by the module:

- `project_id`: The GCP project ID (required)
- `name`: Name for the KEDA installation (default: "keda")
- `namespace`: Kubernetes namespace for KEDA (default: "keda")
- `chart_version`: Version of the KEDA Helm chart (default: "2.17.0")
- `existing_service_account_email`: Email of the existing service account to use (required)
- `permissions`: List of IAM roles to assign to the service account

### 4. Define Outputs (keda/outputs.tf)

The `outputs.tf` file exposes important values from the module:

- `service_account_email`: Email of the Google service account
- `helm_status`: Status of the KEDA Helm release
- `namespace`: Namespace where KEDA is installed

### 5. Update Root Module (main.tf)

The root `main.tf` file is updated to call the KEDA module:

```hcl
module "keda" {
  source = "./keda"
  
  project_id = var.project_id
  chart_version = "2.17.0"
  
  # Use the existing workload identity service account
  existing_service_account_email = module.iam.workload_identity_sa_email
  
  depends_on = [
    module.gke
  ]
}
```

The `depends_on` attribute ensures that KEDA is installed only after the GKE cluster is created. The module uses the existing Workload Identity service account from the IAM module.

### 6. Update IAM Module (iam/main.tf)

The IAM module's Workload Identity binding is updated to include the KEDA operator's Kubernetes service account:

```hcl
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.workload_identity_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/default]",
    "serviceAccount:${var.project_id}.svc.id.goog[keda/keda-operator]"
  ]
}
```

This allows the KEDA operator to use the existing Google service account's permissions.

### 7. Configure Providers (providers.tf)

The `providers.tf` file includes the Helm and Kubernetes providers needed for KEDA installation:

```hcl
provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }

data "google_client_config" "default" {}
```

## Authentication Flow

KEDA authenticates with Google Cloud services through Workload Identity Federation:

1. The KEDA Helm chart creates a Kubernetes service account named `keda-operator` in the `keda` namespace
2. We add this Kubernetes service account to the existing Workload Identity binding in the IAM module
3. This binding allows the `keda-operator` service account to act as the existing Google service account
4. When KEDA needs to access Google Cloud services (like Cloud SQL or Compute Engine), it automatically receives the appropriate credentials
5. No service account keys are stored in the cluster
6. The same Google service account is reused across multiple components, following the principle of least accounts

## Permissions

The additional permissions added to the existing Workload Identity service account for KEDA are:

- `roles/monitoring.viewer`: For general metrics-based scaling
- `roles/cloudsql.viewer`: For Cloud SQL database scaling
- `roles/compute.viewer`: For Compute Engine instance scaling
- `roles/spanner.databaseReader`: For Spanner database scaling

These permissions are added to the existing permissions the service account already has.

## Managing KEDA Permissions

To add or modify permissions for KEDA:

1. **For standard scaling permissions**: Edit the `permissions` variable in `keda/variables.tf`
   ```hcl
   variable "permissions" {
     description = "List of additional IAM roles to assign to the existing service account for KEDA"
     type        = list(string)
     default     = [
       "roles/monitoring.viewer",
       "roles/cloudsql.viewer",
       # Add new permissions here
     ]
   }
   ```

2. **For project-specific overrides**: Override in the root `main.tf` when calling the module
   ```hcl
   module "keda" {
     source = "./keda"
     
     project_id = var.project_id
     existing_service_account_email = module.iam.workload_identity_sa_email
     
     # Override default permissions
     permissions = [
       "roles/monitoring.viewer",
       "roles/cloudsql.viewer",
       "roles/pubsub.subscriber",  # Add project-specific permission
     ]
     
     depends_on = [module.gke]
   }
   ```

This approach allows for flexible permission management while maintaining the principle of least privilege.

## Verification

After applying the Terraform configuration, you can verify KEDA installation:

```bash
# Configure kubectl
gcloud container clusters get-credentials cdsci-cluster --region us-central1 --project cdsci-test

# Check KEDA pods
kubectl get pods -n keda

# Verify KEDA CRDs
kubectl get crd | grep keda
```

## Maintenance

To update KEDA:

1. Change the `chart_version` variable in the module call or in the module's `variables.tf`
2. Apply the Terraform configuration

To add new permissions:

1. Update the `permissions` variable in the module's `variables.tf`
2. Apply the Terraform configuration

## Conclusion

This modular approach to KEDA installation provides a clean, maintainable, and secure way to implement event-driven autoscaling in the CDSCI project. By reusing the existing service account and adding the KEDA operator to the Workload Identity binding, we maintain a secure authentication flow without creating unnecessary service accounts or keys.