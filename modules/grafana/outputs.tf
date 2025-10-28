output "grafana_service_endpoint" {
  description = "Grafana internal service endpoint"
  value       = "http://grafana.${var.observability_namespace}.svc.cluster.local"
}

output "grafana_password_ssm_parameter" {
  description = "SSM parameter name containing Grafana admin password"
  value       = aws_ssm_parameter.grafana_password.name
}
