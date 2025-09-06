resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "traefik"
  chart            = "traefik"
  namespace        = var.namespace
  create_namespace = var.create_namespace
  version          = var.chart_version

  values = [
    yamlencode({
      # Use LoadBalancer service type
      service = {
        type = "LoadBalancer"
      }

      # Configure ports for HTTP and HTTPS (using non-privileged ports for GKE Autopilot)
      ports = {
        web = {
          port        = 8000 # Non-privileged port inside container
          exposedPort = 80   # External LoadBalancer port
        }
        websecure = {
          port        = 8443 # Non-privileged port inside container
          exposedPort = 443  # External LoadBalancer port
          tls = {
            enabled = true
          }
        }
        traefik = {
          port = 8080
          expose = {
            default = true # Dashboard access
          }
        }
      }



      # Let's Encrypt configuration for automatic SSL
      certificatesResolvers = {
        letsencrypt = {
          acme = {
            email   = var.letsencrypt_email
            storage = "/data/acme.json"
            httpChallenge = {
              entryPoint = "web"
            }
          }
        }
      }

      # Enable API and Dashboard
      api = {
        dashboard = true
        insecure  = true # Required for IngressRoute access to dashboard
      }

      # Additional arguments to ensure API is properly configured
      additionalArguments = [
        "--api.insecure=true"
      ]

      # Disable default dashboard IngressRoute (we'll create custom ones)
      ingressRoute = {
        dashboard = {
          enabled = false
        }
      }

      # Enable logging for troubleshooting
      log = {
        level = "INFO"
      }
      accessLog = {}
    })
  ]
}
