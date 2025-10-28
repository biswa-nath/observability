output "loki_endpoint" {
  description = "Loki service endpoint"
  value       = "http://loki-gateway.${var.observability_namespace}.svc.cluster.local"
}
