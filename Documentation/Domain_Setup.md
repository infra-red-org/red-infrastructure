# Domain Configuration Guide

This guide explains how to configure your own domain for the Traefik monitoring routing setup.

## Quick Setup

1. **Update terraform.tfvars** with your domain and email:

   ```hcl
   # Domain and SSL configuration
   letsencrypt_email = "your-email@yourdomain.com"        # Your actual email for Let's Encrypt
   prometheus_domain = "gke-prometheus.yourdomain.com"    # Your Prometheus subdomain
   grafana_domain    = "gke-grafana.yourdomain.com"       # Your Grafana subdomain
   traefik_domain    = "gke-traefik.yourdomain.com"       # Your Traefik dashboard subdomain
   ```
2. **Deploy the infrastructure**:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
3. **Get the LoadBalancer IP** from the output:

   ```bash
   terraform output traefik_ip
   ```
4. **Create DNS A records** pointing to the LoadBalancer IP:

   ```
   gke-prometheus.yourdomain.com  A  <TRAEFIK_EXTERNAL_IP>
   gke-grafana.yourdomain.com     A  <TRAEFIK_EXTERNAL_IP>
   gke-traefik.yourdomain.com     A  <TRAEFIK_EXTERNAL_IP>
   ```
5. **Apply the Kubernetes manifests**:

   ```bash
   kubectl apply -f k8s-manifests/traefik_dashboard.yaml
   kubectl apply -f k8s-manifests/monitoring-ingress-routes.yaml
   ```

## Access URLs

After DNS propagation (usually 5-15 minutes), you can access:

- **Traefik Dashboard**: https://gke-traefik.yourdomain.com
- **Prometheus**: https://gke-prometheus.yourdomain.com
- **Grafana**: https://gke-grafana.yourdomain.com

## SSL Certificates

Let's Encrypt will automatically provision SSL certificates for all domains. The certificates will be renewed automatically.

## Troubleshooting

1. **Check DNS propagation**:

   ```bash
   nslookup gke-traefik.yourdomain.com
   ```
2. **Check certificate status**:

   ```bash
   kubectl get certificates -n traefik-v2
   kubectl get certificates -n monitoring
   ```
3. **Check Traefik logs**:

   ```bash
   kubectl logs -n traefik-v2 deployment/traefik
   ```

## Default Credentials

- **Grafana**: admin / prom-operator (change after first login)
- **Prometheus**: No authentication required
- **Traefik Dashboard**: No authentication required (API is insecure for development)
