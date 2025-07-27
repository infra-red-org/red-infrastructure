# Monitoring Access Guide

## Overview

This guide provides step-by-step instructions for accessing Prometheus, Grafana, and Traefik dashboard through domain-based routing with automatic HTTPS/SSL certificates from Let's Encrypt. The setup provides a production-ready monitoring stack with proper SSL termination and certificate management.

## Quick Start

### 1. Get Traefik External IP and DNS Requirements

```bash
# Get the LoadBalancer IP
terraform output traefik_ip

# Get required DNS records
terraform output dns_records_needed
```

### 2. Configure DNS Records

Create A records pointing to the LoadBalancer IP:
```
gke-prometheus.yourdomain.com  A  <TRAEFIK_EXTERNAL_IP>
gke-grafana.yourdomain.com     A  <TRAEFIK_EXTERNAL_IP>
gke-traefik.yourdomain.com     A  <TRAEFIK_EXTERNAL_IP>
```

### 3. Access Monitoring Interfaces

- **Prometheus**: `https://gke-prometheus.yourdomain.com`
- **Grafana**: `https://gke-grafana.yourdomain.com` (admin/prom-operator)
- **Traefik Dashboard**: `https://gke-traefik.yourdomain.com`

## Detailed Access Instructions

### Step 1: Infrastructure Deployment and DNS Setup

**Deploy the infrastructure:**
```bash
cd red-infrastructure
terraform init
terraform plan
terraform apply
```

**Get the required information:**
```bash
# Get LoadBalancer IP
export TRAEFIK_IP=$(terraform output -raw traefik_ip)
echo "Traefik LoadBalancer IP: $TRAEFIK_IP"

# Get DNS records needed
terraform output dns_records_needed
```

**Configure DNS records** in your domain provider:
```
gke-prometheus.yourdomain.com  A  <TRAEFIK_IP>
gke-grafana.yourdomain.com     A  <TRAEFIK_IP>
gke-traefik.yourdomain.com     A  <TRAEFIK_IP>
```

**Apply Kubernetes manifests:**
```bash
kubectl apply -f k8s-manifests/traefik_dashboard.yaml
kubectl apply -f k8s-manifests/monitoring-ingress-routes.yaml
```

**Wait for DNS propagation** (usually 5-15 minutes):
```bash
# Test DNS resolution
nslookup gke-prometheus.yourdomain.com
nslookup gke-grafana.yourdomain.com
nslookup gke-traefik.yourdomain.com
```

### Step 2: SSL Certificate Verification

**Check certificate provisioning:**
```bash
# Check certificate resources
kubectl get certificates -A

# Check certificate status
kubectl describe certificate -n monitoring prometheus-tls
kubectl describe certificate -n monitoring grafana-tls
kubectl describe certificate -n traefik-v2 traefik-tls
```

**Verify SSL certificates:**
```bash
# Check certificate details
echo | openssl s_client -servername gke-traefik.yourdomain.com -connect gke-traefik.yourdomain.com:443 2>/dev/null | openssl x509 -noout -subject -issuer -dates

# Should show:
# subject=CN=gke-traefik.yourdomain.com
# issuer=C=US, O=Let's Encrypt, CN=R11
# notBefore=...
# notAfter=...
```

### Step 3: Access Prometheus Web Interface

**URL**: `https://gke-prometheus.yourdomain.com`

**Features Available:**
- Execute PromQL queries to explore metrics
- Browse available metrics and their labels
- View target discovery and scrape health
- Check configuration and alerting rules
- Monitor Prometheus server status

**First-time verification:**
1. Navigate to the Prometheus HTTPS URL
2. Verify SSL certificate is valid (green lock icon)
3. Go to "Status" → "Targets" to verify scrape targets are healthy
4. Try a simple query like `up` to test functionality
5. Check "Status" → "Configuration" to verify external URL configuration

### Step 4: Access Grafana Dashboard

**URL**: `https://gke-grafana.yourdomain.com`

**Default Login Credentials:**
- **Username**: `admin`
- **Password**: `prom-operator`

**Important Security Steps:**
1. Log in with default credentials
2. **Immediately change the password**:
   - Click the user icon (bottom left corner)
   - Select "Preferences"
   - Navigate to "Change Password" tab
   - Set a strong, unique password
3. Verify SSL certificate is valid

**Available Features:**
- Pre-configured Kubernetes monitoring dashboards
- Custom dashboard creation and management
- Data source configuration (Prometheus is pre-configured)
- User and team management
- Alerting and notification setup

### Step 5: Access Traefik Dashboard

**URL**: `https://gke-traefik.yourdomain.com`

**Features Available:**
- HTTP/HTTPS routes and their health status
- SSL certificate status and management
- Service discovery information
- Middleware configuration and status
- Real-time request metrics and statistics
- Backend service health
- Let's Encrypt certificate provisioning status

## SSL Certificate Management

### Automatic Certificate Provisioning

**How it works:**
- Traefik automatically requests certificates from Let's Encrypt
- Uses HTTP challenge method for domain validation
- Certificates are stored in Traefik's persistent storage
- Automatic renewal before expiration

**Certificate storage:**
```bash
# Check certificate storage in Traefik
kubectl exec -n traefik-v2 deployment/traefik -- ls -la /data/

# View ACME certificate data
kubectl exec -n traefik-v2 deployment/traefik -- cat /data/acme.json | jq .
```

### Certificate Troubleshooting

**Check certificate request status:**
```bash
# Monitor Traefik logs for certificate requests
kubectl logs -n traefik-v2 deployment/traefik | grep -i acme

# Check for certificate errors
kubectl logs -n traefik-v2 deployment/traefik | grep -i "certificate\|ssl\|tls"
```

**Common certificate issues:**
1. **DNS not propagated**: Wait for DNS propagation
2. **HTTP challenge blocked**: Ensure port 80 is accessible
3. **Rate limiting**: Let's Encrypt has rate limits per domain
4. **Domain validation failed**: Verify DNS records are correct

## Troubleshooting Guide

### Issue 1: DNS Resolution Problems

**Symptoms:**
- Cannot reach domains via HTTPS
- Browser shows "site can't be reached"
- DNS lookup failures

**Diagnosis:**
```bash
# Test DNS resolution
nslookup gke-prometheus.yourdomain.com
nslookup gke-grafana.yourdomain.com
nslookup gke-traefik.yourdomain.com

# Check if LoadBalancer IP is correct
kubectl get svc -n traefik-v2 traefik
terraform output traefik_ip
```

**Solutions:**
- Verify DNS records are correctly configured
- Wait for DNS propagation (up to 24 hours)
- Check with DNS provider for propagation status
- Test from different networks/locations

### Issue 2: SSL Certificate Not Provisioned

**Symptoms:**
- Browser shows SSL certificate errors
- "Certificate not trusted" warnings
- HTTPS connections fail

**Diagnosis:**
```bash
# Check Traefik logs for ACME errors
kubectl logs -n traefik-v2 deployment/traefik | grep -i "acme\|certificate"

# Check certificate status
kubectl get certificates -A

# Test HTTP challenge accessibility
curl -I http://gke-traefik.yourdomain.com/.well-known/acme-challenge/test
```

**Solutions:**
```bash
# Restart Traefik to retry certificate provisioning
kubectl rollout restart deployment -n traefik-v2 traefik

# Check Let's Encrypt rate limits
# https://letsencrypt.org/docs/rate-limits/

# Verify HTTP challenge is accessible
curl -v http://gke-traefik.yourdomain.com
```

### Issue 3: Cannot Access Services via HTTPS

**Symptoms:**
- SSL works but services return 404 or 502
- Traefik dashboard accessible but monitoring services are not

**Diagnosis:**
```bash
# Check IngressRoute configuration
kubectl get ingressroute -A

# Verify IngressRoute status
kubectl describe ingressroute -n monitoring prometheus-ingress
kubectl describe ingressroute -n monitoring grafana-ingress

# Check service endpoints
kubectl get endpoints -n monitoring
```

**Solutions:**
```bash
# Verify services are running
kubectl get pods -n monitoring

# Check service names match IngressRoute configuration
kubectl get svc -n monitoring

# Recreate IngressRoutes if needed
kubectl apply -f k8s-manifests/monitoring-ingress-routes.yaml
```

### Issue 4: HTTP to HTTPS Redirect Issues

**Symptoms:**
- HTTP requests don't redirect to HTTPS
- Mixed content warnings
- Redirect loops

**Diagnosis:**
```bash
# Test HTTP redirect
curl -I http://gke-traefik.yourdomain.com

# Check redirect middleware
kubectl get middleware -A | grep redirect

# Verify middleware configuration
kubectl get middleware -n traefik-v2 https-redirect -o yaml
kubectl get middleware -n monitoring https-redirect -o yaml
```

**Solutions:**
```bash
# Check IngressRoute middleware references
kubectl get ingressroute -A -o yaml | grep -A 5 -B 5 middleware

# Verify redirect middleware exists in correct namespaces
kubectl apply -f k8s-manifests/traefik_dashboard.yaml
kubectl apply -f k8s-manifests/monitoring-ingress-routes.yaml
```

## Security Best Practices

### Immediate Security Steps

1. **Change Default Passwords:**
   - Change Grafana admin password immediately after first login
   - Use strong, unique passwords

2. **Verify SSL Configuration:**
   ```bash
   # Test SSL configuration
   curl -I https://gke-grafana.yourdomain.com
   curl -I https://gke-prometheus.yourdomain.com
   curl -I https://gke-traefik.yourdomain.com
   ```

3. **Monitor Certificate Expiration:**
   ```bash
   # Check certificate expiration dates
   echo | openssl s_client -servername gke-traefik.yourdomain.com -connect gke-traefik.yourdomain.com:443 2>/dev/null | openssl x509 -noout -dates
   ```

### Production Hardening

For production environments, consider:

- **Disable Traefik insecure API** (`api.insecure = false`)
- **Implement authentication middleware** for additional security
- **Set up network policies** to restrict pod-to-pod communication
- **Use secrets management** for sensitive configuration
- **Enable audit logging** for access monitoring
- **Configure firewall rules** to restrict access by IP
- **Set up monitoring alerts** for certificate expiration

## Monitoring the Monitoring Stack

### Key Metrics to Monitor

**SSL Certificate Health:**
```promql
# Certificate expiration (if metrics enabled)
traefik_tls_certs_not_after

# Certificate provisioning errors
increase(traefik_acme_certificates_total{status="error"}[1h])
```

**Service Health:**
```promql
# Service availability
up{job="prometheus"}
up{job="grafana"}

# Request success rate
rate(traefik_http_requests_total{code!~"4.."}[5m]) / rate(traefik_http_requests_total[5m])
```

### Useful Commands for Monitoring

```bash
# Check all HTTPS services
curl -I https://gke-prometheus.yourdomain.com
curl -I https://gke-grafana.yourdomain.com
curl -I https://gke-traefik.yourdomain.com

# Monitor certificate renewal
kubectl logs -n traefik-v2 deployment/traefik | grep -i "certificate renewed"

# Check service health
kubectl get pods -A | grep -E "(traefik|prometheus|grafana)"
```

## Quick Reference Commands

```bash
# Get LoadBalancer IP
terraform output traefik_ip

# Get DNS records needed
terraform output dns_records_needed

# Check certificate status
kubectl get certificates -A

# Check IngressRoutes
kubectl get ingressroute -A

# Monitor Traefik logs
kubectl logs -n traefik-v2 deployment/traefik -f

# Check service status
kubectl get svc -A | grep -E "(traefik|prometheus|grafana)"

# Test SSL certificates
echo | openssl s_client -servername gke-traefik.yourdomain.com -connect gke-traefik.yourdomain.com:443 2>/dev/null | openssl x509 -noout -subject -issuer -dates

# Check DNS resolution
nslookup gke-prometheus.yourdomain.com
```

## Domain Configuration for Your Own Domain

When you get your own domain, update these files:

1. **Update terraform.tfvars:**
   ```hcl
   letsencrypt_email = "your-email@yourdomain.com"
   prometheus_domain = "gke-prometheus.yourdomain.com"
   grafana_domain    = "gke-grafana.yourdomain.com"
   traefik_domain    = "gke-traefik.yourdomain.com"
   ```

2. **Deploy and configure DNS:**
   ```bash
   terraform apply
   # Configure DNS A records as shown in terraform output
   ```

3. **Apply manifests:**
   ```bash
   kubectl apply -f k8s-manifests/traefik_dashboard.yaml
   kubectl apply -f k8s-manifests/monitoring-ingress-routes.yaml
   ```

## Support and Additional Resources

- **Traefik Documentation**: https://doc.traefik.io/traefik/
- **Let's Encrypt Documentation**: https://letsencrypt.org/docs/
- **Prometheus Documentation**: https://prometheus.io/docs/
- **Grafana Documentation**: https://grafana.com/docs/
- **Kubernetes Troubleshooting**: https://kubernetes.io/docs/tasks/debug-application-cluster/

For infrastructure-specific issues, refer to the [DOMAIN_SETUP.md](../DOMAIN_SETUP.md) guide or the main project documentation.