# Testing KEDA Service Account with Workload Identity Federation

This document explains how to verify that the KEDA operator's Kubernetes service account is correctly configured with Workload Identity Federation to use a Google Cloud service account.

## Prerequisites

- A GKE cluster with KEDA installed
- `kubectl` configured to access the cluster
- The KEDA operator service account should be annotated with the Google service account

## Verifying the Service Account Annotation

First, check if the KEDA operator service account has the correct annotation:

```bash
kubectl describe serviceaccount keda-operator -n keda
```

Look for the annotation:
```
Annotations:         iam.gke.io/gcp-service-account: workload-identity-sa@your-project.iam.gserviceaccount.com
```

If this annotation is missing, add it manually:
```bash
kubectl annotate serviceaccount keda-operator -n keda \
  iam.gke.io/gcp-service-account=workload-identity-sa@your-project.iam.gserviceaccount.com
```

## Testing Workload Identity Authentication

To verify that the KEDA operator can authenticate as the Google service account, create a test pod that uses the same Kubernetes service account:

```bash
kubectl run test-keda-auth --image=google/cloud-sdk:slim -n keda \
  --overrides='{"spec":{"serviceAccountName":"keda-operator"}}' \
  --command -- /bin/bash -c "gcloud auth list && sleep 3600"
```

This command:
1. Creates a pod named `test-keda-auth` in the `keda` namespace
2. Uses the Google Cloud SDK image
3. Runs with the `keda-operator` service account
4. Executes `gcloud auth list` to show the active credentials

## Checking the Results

Check the logs of the test pod:

```bash
kubectl logs test-keda-auth -n keda
```

If Workload Identity is configured correctly, you should see output like:

```
                     Credentialed Accounts
ACTIVE  ACCOUNT
*       workload-identity-sa@your-project.iam.gserviceaccount.com
```

This confirms that the pod running as the `keda-operator` service account is automatically authenticated as the Google service account.

## Testing Access to Google Cloud Resources

To verify that the service account has the necessary permissions, you can run commands that access Google Cloud resources:

```bash
# Create a pod that tests specific permissions
kubectl run test-keda-perms --image=google/cloud-sdk:slim -n keda \
  --overrides='{"spec":{"serviceAccountName":"keda-operator"}}' \
  --command -- /bin/bash -c "gcloud sql instances list && gcloud compute instances list && sleep 3600"

# Check the logs
kubectl logs test-keda-perms -n keda
```

If the service account has the correct permissions, these commands should succeed and show the available resources.

## Cleanup

After testing, delete the test pods:

```bash
kubectl delete pod test-keda-auth -n keda
kubectl delete pod test-keda-perms -n keda
```

## Troubleshooting

If the test pod doesn't show the Google service account:

1. Verify the IAM binding in Google Cloud:
   ```bash
   gcloud iam service-accounts get-iam-policy workload-identity-sa@your-project.iam.gserviceaccount.com
   ```

2. Check that the annotation on the service account is correct:
   ```bash
   kubectl get serviceaccount keda-operator -n keda -o yaml
   ```

3. Restart the KEDA operator pod to pick up any changes:
   ```bash
   kubectl rollout restart deployment keda-operator -n keda
   ```

4. Check the GKE Workload Identity logs:
   ```bash
   kubectl logs -n kube-system -l k8s-app=gke-metadata-server
   ```