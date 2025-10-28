output "tempo_endpoint" {
  description = "Tempo service endpoint"
  value       = "http://tempo.${var.observability_namespace}.svc.cluster.local:3200"
}

output "tempo_otlp_grpc_endpoint" {
  description = "Tempo OTLP gRPC endpoint"
  value       = "tempo.${var.observability_namespace}.svc.cluster.local:4317"
}

output "tempo_otlp_http_endpoint" {
  description = "Tempo OTLP HTTP endpoint"
  value       = "http://tempo.${var.observability_namespace}.svc.cluster.local:4318"
}
