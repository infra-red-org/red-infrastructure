# Load Balancer and Monitoring Setup Documentation

## Overview

This document outlines the process of setting up Traefik (Load Balancer) and Kube-Prometheus-Stack (Monitoring) on GKE Autopilot using Terraform and Helm.

## Prerequisites

- GKE Autopilot cluster
- Terraform with Helm provider
- kubectl configured with cluster access
- Helm CLI (for local testing and CI/CD)

## Key Challenges and Solutions

### 1. Helm Provider Version Issues

#### Problem

Initially used Helm provider 2.x which had authentication issues with GKE clusters.

#### Solution: Upgrade to Helm Provider 3.x

```hcl
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
```

#### Authentication Configuration for Helm 3.x

```hcl
provider "helm" {
  kubernetes {
    host  = "https://${module.gke.cluster_endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
}
```

**Why the upgrade was necessary:**

- Helm provider 2.x had connectivity issues with GKE clusters
- Version 3.x provides better authentication mechanisms
- Improved support for modern Kubernetes authentication methods

### 2. Repository Configuration Strategy

#### Local Development vs CI/CD

Two approaches for Helm repository configuration:

**Option 1: Repository Names (Local Development)**

```hcl
resource "helm_release" "traefik" {
  repository = "traefik"  # Uses local helm repo
  chart      = "traefik"
}
```

**Option 2: Repository URLs (CI/CD Compatible)**

```hcl
resource "helm_release" "traefik" {
  repository = "https://traefik.github.io/charts"  # Direct URL
  chart      = "traefik"
}
```

**Decision:** Use repository names for reliability, add repo setup to CI/CD pipeline.

### Key Configuration Points

- **LoadBalancer Service**: Exposes Traefik to the internet
- **Dashboard Port**: Port 8080 must be explicitly exposed
- **Insecure API**: Enabled for easy access (disable in production)

### Accessing the Dashboard

1. Get external IP: `kubectl get svc -n traefik-v2`
2. Access: `http://<EXTERNAL_IP>:8080/dashboard/`

> **Note**: For comprehensive access instructions including Prometheus and Grafana access through Traefik routing, see the [Monitoring Access Guide](Documentation/monitoring_access.md).

### GKE Autopilot Restrictions

For detailed information about GKE Autopilot restrictions and their impact on monitoring setup, see [GKE Autopilot Restrictions](Auto_Pilot_GKE_restrictions.md).

Why These Restrictions?

1. **kube-system namespace**: Managed by GKE, user access denied
2. **Node-level monitoring**: Not available in Autopilot
3. **System components**: Managed by Google, not accessible
4. **Admission webhooks**: Conflict with GKE's built-in webhooks

### What You Can Still Monitor

- Application pods and containers
- Kubernetes API objects (deployments, services, etc.)
- Custom application metrics
- Container resource usage (via cAdvisor)

## Testing Configuration Before Apply

Use Helm template command to validate configuration:

```bash
# Create test values file
cat > /tmp/test-values.yaml << EOF
prometheusOperator:
  admissionWebhooks:
    enabled: false
# ... other values
EOF

# Test render templates
helm template test-release prometheus-community/kube-prometheus-stack \
  -f /tmp/test-values.yaml \
  --namespace monitoring
```

Look for any resources trying to access `kube-system` namespace.

## CI/CD Pipeline Integration

### Required Helm Repositories

Add these steps to your CI/CD pipeline before running Terraform:

```yaml
# GitHub Actions / GitLab CI example
- name: Setup Helm repositories
  run: |
    helm repo add traefik https://traefik.github.io/charts
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add kedacore https://kedacore.github.io/charts
    helm repo update

- name: Verify repositories
  run: helm repo list

- name: Run Terraform
  run: |
    terraform init
    terraform plan
    terraform apply -auto-approve
```

### Alternative: Use Repository URLs

If you prefer not to manage repositories in CI/CD, update all Helm releases to use direct URLs:

```hcl
repository = "https://traefik.github.io/charts"
repository = "https://prometheus-community.github.io/helm-charts"
repository = "https://kedacore.github.io/charts"
```

## Troubleshooting Common Issues

### 1. "Chart.yaml file is missing"

- **Cause**: Terraform looking for local chart directory
- **Solution**: Use repository URLs or ensure repo is added

### 2. "Kubernetes cluster unreachable"

- **Cause**: Helm provider authentication issues
- **Solution**: Verify provider configuration and cluster credentials

### 3. "services is forbidden in kube-system"

- **Cause**: GKE Autopilot restrictions
- **Solution**: Disable components that access kube-system

### 4. "cannot re-use a name that is still in use"

- **Cause**: Failed Helm release still exists
- **Solution**: `helm uninstall <release-name> -n <namespace>`

### 5. Traefik dashboard not accessible

- **Cause**: Dashboard port not exposed through LoadBalancer
- **Solution**: Configure ports.traefik.expose in Helm values

## Monitoring Strategy for GKE Autopilot

### Recommended Approach

1. **Application Metrics**: Use Prometheus for custom app metrics
2. **Infrastructure Metrics**: Use Google Cloud Monitoring
3. **Container Metrics**: Use cAdvisor scrape config
4. **Kubernetes Objects**: Use kube-state-metrics

### Google Cloud Monitoring Integration

- Automatically enabled in GKE
- Access: https://console.cloud.google.com/monitoring
- Provides node and cluster-level metrics
- Complements Prometheus for application monitoring

## Security Considerations

### Production Recommendations

1. **Disable insecure API**: Set `api.insecure = false`
2. **Enable TLS**: Configure proper certificates
3. **Network policies**: Restrict dashboard access
4. **RBAC**: Implement proper service account permissions
5. **Secrets management**: Use Kubernetes secrets for sensitive data

## Accessing Monitoring Interfaces

### Overview

With the Traefik routing configuration, you can access Prometheus, Grafana, and the Traefik dashboard through domain-based routing with automatic HTTPS/SSL certificates from Let's Encrypt. This provides a production-ready setup with proper SSL termination.

### Domain-Based Access Configuration

The current setup uses domain-based routing with automatic SSL certificate provisioning:

#### SSL Certificate Management

- **Certificate Authority**: Let's Encrypt (automatic provisioning)
- **Certificate Resolver**: Configured in Traefik with HTTP challenge
- **Automatic Renewal**: Certificates are automatically renewed before expiration
- **SSL Termination**: Handled by Traefik LoadBalancer

#### Getting the Traefik External IP Address

1. **Get the external IP address:**

   ```bash
   kubectl get svc -n traefik-v2 traefik
   ```

   Look for the `EXTERNAL-IP` column. It may show `<pending>` initially while the LoadBalancer is being provisioned.
2. **Alternative method using Terraform output:**

   ```bash
   terraform output traefik_ip
   ```
3. **Get DNS records needed:**

   ```bash
   terraform output dns_records_needed
   ```

### URL Patterns for Accessing Services

Once DNS records are configured, you can access the monitoring interfaces using these HTTPS URLs:

#### Prometheus Web UI

- **URL**: `https://gke-prometheus.yourdomain.com`
- **SSL**: Automatic Let's Encrypt certificate
- **Features Available**:
  - Query interface for PromQL queries
  - Metrics browser and exploration
  - Target discovery and health status
  - Configuration and rule management

#### Grafana Dashboard

- **URL**: `https://gke-grafana.yourdomain.com`
- **SSL**: Automatic Let's Encrypt certificate
- **Default Credentials**:
  - Username: `admin`
  - Password: `prom-operator` (default from kube-prometheus-stack)
- **Features Available**:
  - Pre-configured dashboards for Kubernetes monitoring
  - Custom dashboard creation
  - Data source management
  - User and team management

#### Traefik Dashboard

- **URL**: `https://gke-traefik.yourdomain.com`
- **SSL**: Automatic Let's Encrypt certificate
- **Features Available**:
  - Route visualization and health status
  - Service discovery information
  - Middleware configuration status
  - Real-time traffic metrics
  - SSL certificate status and management

### DNS Configuration Requirements

Before accessing the services, you need to configure DNS records:

1. **Get the LoadBalancer IP:**

   ```bash
   terraform output traefik_ip
   ```
2. **Create DNS A records** pointing to the LoadBalancer IP:

   ```
   gke-prometheus.yourdomain.com  A  <TRAEFIK_EXTERNAL_IP>
   gke-grafana.yourdomain.com     A  <TRAEFIK_EXTERNAL_IP>
   gke-traefik.yourdomain.com     A  <TRAEFIK_EXTERNAL_IP>
   ```
3. **Apply Kubernetes manifests** for IngressRoutes:

   ```bash
   kubectl apply -f k8s-manifests/traefik_dashboard.yaml
   kubectl apply -f k8s-manifests/monitoring-ingress-routes.yaml
   ```
4. **Wait for DNS propagation** (usually 5-15 minutes)

### Initial Setup Instructions

#### First-Time Grafana Access

1. Navigate to `https://gke-grafana.yourdomain.com`
2. Log in with default credentials (admin/prom-operator)
3. **Important**: Change the default password immediately:
   - Click on the user icon (bottom left)
   - Select "Preferences"
   - Go to "Change Password" tab
   - Set a secure password

#### Verifying Prometheus Configuration

1. Navigate to `https://gke-prometheus.yourdomain.com`
2. Go to "Status" → "Targets" to verify scrape targets are healthy
3. Test a simple query like `up` to ensure metrics are being collected
4. Check "Status" → "Configuration" to verify the external URL is set correctly

#### Verifying SSL Certificates

1. Check certificate details in browser or use:
   ```bash
   echo | openssl s_client -servername gke-traefik.yourdomain.com -connect gke-traefik.yourdomain.com:443 2>/dev/null | openssl x509 -noout -subject -issuer -dates
   ```
2. Verify issuer shows "Let's Encrypt"
3. Check certificate expiration dates

### Troubleshooting Access Issues

#### Common Issues and Solutions

**1. External IP shows as `<pending>`**

```bash
# Check LoadBalancer service status
kubectl describe svc -n traefik-v2 traefik

# Check for any events or errors
kubectl get events -n traefik-v2 --sort-by='.lastTimestamp'
```

**2. Cannot access Prometheus via domain**

```bash
# Check DNS resolution
nslookup gke-prometheus.yourdomain.com

# Check if IngressRoute exists and is configured correctly
kubectl get ingressroute -n monitoring prometheus-ingress -o yaml

# Verify Prometheus service is running
kubectl get svc -n monitoring | grep prometheus

# Check Prometheus pod status
kubectl get pods -n monitoring | grep prometheus

# Check SSL certificate status
kubectl get certificates -n monitoring
```

**3. Cannot access Grafana via domain**

```bash
# Check DNS resolution
nslookup gke-grafana.yourdomain.com

# Check if IngressRoute exists and is configured correctly
kubectl get ingressroute -n monitoring grafana-ingress -o yaml

# Verify Grafana service is running
kubectl get svc -n monitoring | grep grafana

# Check Grafana pod status
kubectl get pods -n monitoring | grep grafana

# Check SSL certificate status
kubectl get certificates -n monitoring
```

**4. Grafana login issues or styling problems**

```bash
# Check Grafana configuration for subpath settings
kubectl get configmap -n monitoring kube-prometheus-stack1-grafana -o yaml | grep -A 10 -B 10 "root_url\|serve_from_sub_path"

# Check Grafana logs for configuration errors
kubectl logs -n monitoring deployment/kube-prometheus-stack1-grafana
```

**5. Assets not loading correctly (CSS/JS broken)**

```bash
# Verify StripPrefix middleware is configured
kubectl get middleware -n monitoring -o yaml

# Check Traefik dashboard for route status
# Navigate to http://<TRAEFIK_IP>:8080/dashboard/ and check HTTP routes
```

#### Debugging Commands

**Check IngressRoute Status:**

```bash
# List all IngressRoutes
kubectl get ingressroute -A

# Describe specific IngressRoute for detailed status
kubectl describe ingressroute -n monitoring prometheus-ingress
kubectl describe ingressroute -n monitoring grafana-ingress
```

**Verify Service Discovery:**

```bash
# Check if services exist with correct names
kubectl get svc -n monitoring | grep -E "(prometheus|grafana)"

# Verify service endpoints
kubectl get endpoints -n monitoring | grep -E "(prometheus|grafana)"
```

**Check Middleware Configuration:**

```bash
# List all middlewares
kubectl get middleware -n monitoring

# Check middleware configuration
kubectl get middleware -n monitoring prometheus-stripprefix -o yaml
kubectl get middleware -n monitoring grafana-stripprefix -o yaml
```

**Monitor Traefik Logs:**

```bash
# Get Traefik pod name
kubectl get pods -n traefik-v2

# Follow Traefik logs for routing issues
kubectl logs -n traefik-v2 -f <traefik-pod-name>
```

**Test Service Connectivity:**

```bash
# Port forward to test direct service access
kubectl port-forward -n monitoring svc/kube-prometheus-stack1-prometheus 9090:9090
kubectl port-forward -n monitoring svc/kube-prometheus-stack1-grafana 3000:80

# Test in another terminal
curl http://localhost:9090/-/healthy
curl http://localhost:3000/api/health
```

#### Network Connectivity Tests

**Test from within the cluster:**

```bash
# Create a test pod for network debugging
kubectl run test-pod --image=curlimages/curl -i --tty --rm -- sh

# From within the test pod, test service connectivity:
curl http://kube-prometheus-stack1-prometheus.monitoring.svc.cluster.local:9090/-/healthy
curl http://kube-prometheus-stack1-grafana.monitoring.svc.cluster.local/api/health
```

**Verify DNS Resolution:**

```bash
# Test DNS resolution from test pod
nslookup kube-prometheus-stack1-prometheus.monitoring.svc.cluster.local
nslookup kube-prometheus-stack1-grafana.monitoring.svc.cluster.local
```

### Security Considerations

#### Production Hardening Checklist

- [ ] Change Grafana default admin password
- [ ] Disable Traefik insecure API (`api.insecure = false`)
- [ ] Enable TLS/HTTPS with proper certificates
- [ ] Configure network policies to restrict access
- [ ] Set up proper RBAC for service accounts
- [ ] Use Kubernetes secrets for sensitive configuration
- [ ] Consider authentication middleware for Traefik routes

#### Access Control Recommendations

1. **Restrict LoadBalancer Access**: Use GCP firewall rules to limit source IPs
2. **Enable Authentication**: Configure OAuth or basic auth for Grafana
3. **Monitor Access**: Set up logging and alerting for unauthorized access attempts
4. **Regular Updates**: Keep Traefik, Prometheus, and Grafana updated

### Performance Monitoring

#### Key Metrics to Monitor

- **Traefik**: Request latency, error rates, active connections
- **Prometheus**: Query performance, storage usage, scrape duration
- **Grafana**: Dashboard load times, user sessions, query performance

#### Useful Queries for Monitoring the Monitoring Stack

```promql
# Traefik request rate
rate(traefik_http_requests_total[5m])

# Prometheus scrape duration
prometheus_tsdb_compaction_duration_seconds

# Grafana active users
grafana_stat_active_users
```

## Next Steps

1. **Set up Grafana dashboards** for visualization
2. **Configure alerting rules** for critical metrics
3. **Implement ingress rules** for application routing
4. **Set up monitoring for your applications**
5. **Configure backup and disaster recovery**
6. **Secure the monitoring stack** following production hardening guidelines

## Useful Commands

```bash
# Check Helm releases
helm list -A

# Debug Helm release
helm status <release-name> -n <namespace>

# Get service external IPs
kubectl get svc -A

# Port forward for local access
kubectl port-forward -n <namespace> svc/<service> <local-port>:<remote-port>

# Check pod logs
kubectl logs -n <namespace> <pod-name>

# Describe problematic resources
kubectl describe <resource-type> <resource-name> -n <namespace>
```
