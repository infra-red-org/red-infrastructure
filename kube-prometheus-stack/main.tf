# resource "helm_release" "kube_prometheus_stack" {
#   name       = "kube-prometheus-stack"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace  = var.namespace
#   create_namespace = var.create_namespace
# }

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack1"
  repository       = "prometheus-community"
  chart            = "kube-prometheus-stack"
  namespace        = var.namespace
  create_namespace = var.create_namespace

  values = [
    yamlencode({
      prometheusOperator = {
        admissionWebhooks = {
          enabled = false
        }
        tls = {
          enabled = false
        }
        kubeletService = {
          enabled = false
        }
      }
      kubeStateMetrics = {
        enabled = true
      }
      nodeExporter = {
        enabled = false
      }
      kubeControllerManager = {
        enabled = false
      }
      kubeEtcd = {
        enabled = false
      }
      kubeScheduler = {
        enabled = false
      }
      kubeProxy = {
        enabled = false
      }
      kubelet = {
        enabled = false
      }
      coreDns = {
        enabled = false
      }
      kubeApiServer = {
        enabled = false
      }
      defaultRules = {
        rules = {
          kubernetesSystem = false
        }
      }
      prometheus = {
        prometheusSpec = {
          # Configure for subdomain access
          externalUrl = "https://${var.prometheus_domain}"
          additionalScrapeConfigs = [
            {
              job_name     = "kubernetes-pods-cadvisor"
              scheme       = "https"
              metrics_path = "/metrics/cadvisor"
              kubernetes_sd_configs = [
                {
                  role = "node"
                }
              ]
              bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
              tls_config = {
                insecure_skip_verify = true
              }
              relabel_configs = [
                {
                  action = "labelmap"
                  regex  = "__meta_kubernetes_node_label_(.+)"
                }
              ]
            }
          ]
        }
      }
      grafana = {
        "grafana.ini" = {
          server = {
            root_url = "https://${var.grafana_domain}"
            domain   = var.grafana_domain
          }
        }
      }
    })
  ]
}
