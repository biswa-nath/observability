output "prometheus_endpoint" {
  description = "Prometheus service endpoint"
  value       = "http://prometheus-kube-prometheus-prometheus.${var.observability_namespace}.svc.cluster.local:9090"
}

output "alertmanager_endpoint" {
  description = "AlertManager service endpoint"
  value       = "http://prometheus-kube-prometheus-alertmanager.${var.observability_namespace}.svc.cluster.local:9093"
}

output "pushgateway_endpoint" {
  description = "PushGateway service endpoint"
  value       = "http://pushgateway.${var.observability_namespace}.svc.cluster.local:9091"
}
