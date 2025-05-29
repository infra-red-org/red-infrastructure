# IAM Module Documentation

## Overview
The IAM (Identity and Access Management) module configures the necessary service accounts and permissions for the GKE cluster to securely access Google Cloud resources using Workload Identity Federation. This eliminates the need for managing service account keys and provides a more secure authentication method.

## Components

### Workload Identity Service Account
The module creates a Google Cloud service account that will be used by Kubernetes workloads:

- **Account ID**: "workload-identity-sa"
- **Display Name**: "Service Account For Workload Identity"
- **Project**: Specified by the `project_id` variable

### IAM Role Bindings
The module assigns specific IAM roles to the Workload Identity service account:

- **Storage Object Viewer** (`roles/storage.objectViewer`): Allows read-only access to objects in Google Cloud Storage
- **BigQuery Admin** (`roles/bigquery.admin`): Provides full access to BigQuery resources

### Workload Identity Federation Binding
The module configures the binding between Kubernetes service accounts and the Google Cloud service account:

- **Role**: `roles/iam.workloadIdentityUser`
- **Members**: Currently configured for the default Kubernetes service account in the default namespace
- **Format**: `serviceAccount:${var.project_id}.svc.id.goog[default/default]`

## Process Flow

1. **Service Account Creation**:
   - The `google_service_account` resource creates a GCP service account.
   - This account will be used by Kubernetes workloads to access Google Cloud resources.

2. **Role Assignment**:
   - The `google_project_iam_member` resource assigns IAM roles to the service account.
   - A `for_each` loop is used to efficiently assign multiple roles.
   - Currently, the service account is granted Storage Object Viewer and BigQuery Admin roles.

3. **Workload Identity Binding**:
   - The `google_service_account_iam_binding` resource creates the binding between Kubernetes and GCP.
   - This binding allows Kubernetes service accounts to impersonate the GCP service account.
   - Currently configured for the default service account in the default namespace.
   - Comments in the code show other possible configurations for different scopes.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID | string | n/a | yes |
| cluster_sa_id | ID for the cluster service account | string | "gke-cluster-sa" | no |

**Note**: The `cluster_sa_id` variable appears to be defined but not currently used in the module.

## Outputs

| Name | Description |
|------|-------------|
| workload_identity_sa_email | Email address of the Workload Identity service account |
| workload_identity_sa_name | Fully qualified name of the Workload Identity service account |
| workload_identity_sa_id | Unique ID of the Workload Identity service account |
| workload_identity_sa_member | Member string for the Workload Identity service account |

## Usage

The IAM module is typically used in conjunction with the GKE module:

```hcl
module "iam" {
  source     = "./iam"
  project_id = var.project_id
}
```

## Kubernetes Configuration

After applying this Terraform configuration, you need to annotate your Kubernetes service accounts to use Workload Identity:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
  namespace: default
  annotations:
    iam.gke.io/gcp-service-account: workload-identity-sa@${PROJECT_ID}.iam.gserviceaccount.com
```

## Security Considerations

- Workload Identity eliminates the need for service account keys, improving security
- The principle of least privilege is applied by granting only necessary roles
- Consider further restricting the roles based on your application's actual needs
- The current configuration allows any pod using the default service account to access GCP resources
- Consider creating dedicated service accounts for different applications

## Customization Options

The module includes commented examples for different Workload Identity binding patterns:

- Specific namespace and service account: `[<namespace>/<service-account-name>]`
- All service accounts in a specific namespace: `[<namespace>/*]`
- Specific service account in all namespaces: `[*/<service-account-name>]`
- All service accounts in all namespaces: `[*/*]`

Uncomment and modify these patterns based on your security requirements.

## Best Practices

- Create dedicated service accounts for different applications
- Apply the principle of least privilege by granting only necessary permissions
- Regularly audit and review IAM permissions
- Use namespaces to organize and isolate workloads
- Consider implementing more granular IAM bindings for production environments