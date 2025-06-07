# Workload Identity Service Account
resource "google_service_account" "workload_identity_sa" {
  account_id   = "workload-identity-sa"
  display_name = "Service Account For Workload Identity"
  project      = var.project_id
}

# Roles for Workload Identity SA
resource "google_project_iam_member" "workload_identity_roles" {
  for_each = toset([
    "roles/storage.objectViewer", 
    "roles/bigquery.admin"
  ])
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workload_identity_sa.email}"
}

# Workload Identity Federation binding
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.workload_identity_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/default]", # applies to the default namespace
    "serviceAccount:${var.project_id}.svc.id.goog[keda/keda-operator]" # applies to the KEDA operator service account
    # "serviceAccount:${var.project_id}.svc.id.goog[<namespace>/<service-account-name>]" # applies to a specific namespace and service account
    # "serviceAccount:${var.project_id}.svc.id.goog[<namespace>/*]" # applies to all service accounts in a specific namespace
    # "serviceAccount:${var.project_id}.svc.id.goog[*/<service-account-name>]" # applies to a specific service account in all namespaces
    # "serviceAccount:${var.project_id}.svc.id.goog[*/*]" # applies to all service accounts in all namespaces
    # "serviceAccount:${var.project_id}.svc.id.goog[<namespace>/<service-account-name>]" # applies to a specific namespace and service account
    # "serviceAccount:${var.project_id}.svc.id.goog[<namespace>/*]" # applies to all service accounts in a specific namespace
    # "serviceAccount:${var.project_id}.svc.id.goog[<namespace>/<service-account-name>]" # applies to a specific namespace and service account
  ]
}
