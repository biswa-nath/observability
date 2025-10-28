output "alloy_otlp_grpc_endpoint" {
  description = "Alloy OTLP gRPC endpoint for applications"
  value       = "alloy.${var.observability_namespace}.svc.cluster.local:4317"
}

output "alloy_otlp_http_endpoint" {
  description = "Alloy OTLP HTTP endpoint for applications"
  value       = "http://alloy.${var.observability_namespace}.svc.cluster.local:4318"
}
