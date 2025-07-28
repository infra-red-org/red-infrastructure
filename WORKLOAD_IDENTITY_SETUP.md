# Workload Identity Federation Setup

This document explains how the Workload Identity Federation is now fully automated in Terraform.

## What Was Fixed

Previously, the Workload Identity Pool had to be created manually in the GCP Console. Now it's fully automated in Terraform.

## Required Configuration

### 1. Update terraform.tfvars

```hcl
# GitHub repositories for Workload Identity Federation
# IMPORTANT: Replace with actual GitHub repositories in format "owner/repo"
# Add all repositories that should have access to deploy this infrastructure
github_repositories = [
  "infra-red-org/red-infrastructure",
  "IfeanyiSam/red-infrastructure",
  "seandavi/red-infrastructure"
]
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 3. Get Workload Identity Information

After deployment, get the required information for GitHub Actions:

```bash
# Get the Workload Identity Provider name
terraform output workload_identity_provider

# Get the Service Account email
terraform output workload_identity_service_account
```

## GitHub Actions Configuration

Use these outputs to configure your GitHub Actions secrets:

- **`WIF_PROVIDER`**: Use the value from `terraform output workload_identity_provider`
- **`WIF_SERVICE_ACCOUNT`**: Use the value from `terraform output workload_identity_service_account`

## What Gets Created

The Terraform now creates:

1. **Workload Identity Pool** (`terraform-github-pool`)
2. **Workload Identity Pool Provider** (`terraform-github-provider`) 
3. **Service Account** (`terraform-github-sa`)
4. **IAM Bindings** for the service account to impersonate

## Resource Naming

The Terraform uses different resource names than your existing manual setup to avoid conflicts:

| Resource Type | Manual Name | Terraform Name |
|---------------|-------------|----------------|
| Workload Identity Pool | `github-actions-pool` | `terraform-github-pool` |
| Pool Provider | `github-provider` | `terraform-github-provider` |
| Service Account | `github-action-sa` | `terraform-github-sa` |

This allows you to test the Terraform configuration without affecting your existing working setup.

## Security

The Workload Identity Federation is configured to only allow access from your specific GitHub repository, providing secure keyless authentication for GitHub Actions.

## Troubleshooting

If you get errors about Identity Pool not existing:

1. Ensure `github_repositories` is set correctly in `terraform.tfvars`
2. Run `terraform plan` to verify the resources will be created
3. Check that you have the necessary IAM permissions to create Workload Identity resources

## Multiple Repository Access

The configuration supports multiple GitHub repositories. This is useful when:

- **Multiple team members** have forks of the repository
- **Different environments** are deployed from different repositories
- **Shared infrastructure** needs to be accessible from multiple repos

### Adding New Repositories

To add a new repository, simply update the `github_repositories` list in `terraform.tfvars`:

```hcl
github_repositories = [
  "infra-red-org/red-infrastructure",
  "IfeanyiSam/red-infrastructure",
  "seandavi/red-infrastructure",
  "newuser/red-infrastructure"  # Add new repository here
]
```

Then run:
```bash
terraform plan
terraform apply
```

## Required GCP APIs

Ensure these APIs are enabled in your project:

- Identity and Access Management (IAM) API
- Cloud Resource Manager API
- Security Token Service API