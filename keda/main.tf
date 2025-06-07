# Install KEDA using Helm
resource "helm_release" "keda" {
  name             = var.name
  repository       = "kedacore"
  chart            = "keda"
  namespace        = var.namespace
  create_namespace = true
  version          = var.chart_version
}

# Grant necessary permissions to the existing service account
resource "google_project_iam_member" "keda_permissions" {
  for_each = toset(var.permissions)
  
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${var.existing_service_account_email}"
}

# Uncomment this block to automatically annotate the KEDA operator service account
# This ensures the Kubernetes service account can use Workload Identity
# Note: This requires the kubernetes provider to be configured

resource "kubernetes_annotations" "keda_operator_annotation" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = var.k8s_service_account
    namespace = var.namespace
  }
  annotations = {
    "iam.gke.io/gcp-service-account" = var.existing_service_account_email
  }
  depends_on = [helm_release.keda]
}
