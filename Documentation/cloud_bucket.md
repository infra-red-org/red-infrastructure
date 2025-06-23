# Cloud Bucket Documentation

## Overview

The Cloud Bucket module creates a Google Cloud Storage (GCS) bucket that serves as the remote state storage for Terraform. This enables team collaboration, state locking, and version history for infrastructure changes.

## Components

### Google Cloud Storage Bucket

The module provisions a single GCS bucket with the following configurations:

- **Name**: Defined by the `bucket_name` variable
- **Location**: Set to "US" by default, configurable via the `location` variable
- **Versioning**: Enabled to maintain history of state files
- **Uniform Bucket-Level Access**: Enabled for simplified and more secure access control
- **Force Destroy**: Set to `false` to prevent accidental deletion of the bucket with state files

## Process Flow

1. **Provider Configuration**:

   - The Google Cloud provider is configured with the project ID and region.
   - These values are parameterized through variables.
2. **Bucket Creation**:

   - The `google_storage_bucket` resource creates the actual storage bucket.
   - The bucket name is globally unique across Google Cloud.
   - The bucket is configured with versioning enabled to maintain state history.
3. **Access Control**:

   - Uniform bucket-level access is enabled, which means access is controlled at the bucket level rather than individual objects.
   - This simplifies permissions management and improves security.

## Variables

| Name        | Description                                    | Type   | Default | Required |
| ----------- | ---------------------------------------------- | ------ | ------- | :------: |
| project_id  | The ID of the GCP project                      | string | n/a     |   yes   |
| region      | The region for the resources                   | string | n/a     |   yes   |
| bucket_name | The name of the GCS bucket for terraform state | string | n/a     |   yes   |
| location    | The location for the GCS bucket                | string | "US"    |    no    |

## Outputs

| Name        | Description                    |
| ----------- | ------------------------------ |
| bucket_name | The name of the created bucket |
| bucket_url  | The URL of the created bucket  |

## Configuration Template

Create a `terraform.tfvars` file with the following structure:

```hcl
project_id  = "your-project-id"
region      = "your-preferred-region"
bucket_name = "your-unique-bucket-name"
location    = "US"  # or your preferred location
```

> **Note:** The actual `terraform.tfvars` file is not included in the repository for security reasons. You must create your own with values appropriate for your environment.

## Usage

To use this backend infrastructure:

1. Navigate to the backend_infrastructure directory:

   ```bash
   cd red-infrastructure/cloud_bucket
   ```
2. Create your `terraform.tfvars` file using the template above.
3. Initialize Terraform:

   ```bash
   terraform init
   ```
4. Apply the configuration:

   ```bash
   terraform apply
   ```
5. Once created, the bucket can be referenced in other Terraform configurations as a backend:

   ```hcl
   terraform {
     backend "gcs" {
       bucket = "your-unique-bucket-name"
       prefix = "terraform/state"
     }
   }
   ```

## Security Considerations

- The bucket has versioning enabled to prevent accidental state loss
- Uniform bucket-level access is enabled for better security
- Force destroy is disabled to prevent accidental deletion
- Consider enabling bucket encryption for sensitive state files
- Implement appropriate IAM permissions to restrict access to the bucket

## Maintenance

- Regularly review access logs for the bucket
- Consider implementing lifecycle policies for older state versions
- Ensure the bucket is properly secured with appropriate IAM permissions
