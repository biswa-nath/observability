output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = module.ingress.grafana_url
}

output "grafana_password_ssm_parameter" {
  description = "SSM parameter name containing Grafana admin password"
  value       = module.grafana.grafana_password_ssm_parameter
}

output "external_alb_dns" {
  description = "External ALB DNS name for Grafana"
  value       = module.ingress.external_alb_dns
}

output "internal_alb_dns" {
  description = "Internal ALB DNS name for observability services"
  value       = module.ingress.internal_alb_dns
}

output "alloy_external_endpoint" {
  description = "External endpoint for Alloy via internal ALB"
  value       = module.ingress.alloy_external_endpoint
}

output "loki_external_endpoint" {
  description = "External endpoint for Loki via internal ALB"
  value       = module.ingress.loki_external_endpoint
}

output "tempo_external_endpoint" {
  description = "External endpoint for Tempo via internal ALB"
  value       = module.ingress.tempo_external_endpoint
}

output "pushgateway_external_endpoint" {
  description = "External endpoint for PushGateway via internal ALB"
  value       = module.ingress.pushgateway_external_endpoint
}

output "prometheus_endpoint" {
  description = "Prometheus endpoint"
  value       = module.prometheus.prometheus_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket for long-term storage"
  value       = module.storage.s3_bucket_name
}
