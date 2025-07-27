output "release_name" {
  description = "Name of the Kube Prometheus Stack Helm release"
  value       = helm_release.kube_prometheus_stack.name
}

output "namespace" {
  description = "Namespace where Kube Prometheus Stack is deployed"
  value       = helm_release.kube_prometheus_stack.namespace
}