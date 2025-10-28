output "external_alb_dns" {
  description = "External ALB DNS name for Grafana"
  value       = length(kubernetes_ingress_v1.grafana.status) > 0 && length(kubernetes_ingress_v1.grafana.status[0].load_balancer) > 0 && length(kubernetes_ingress_v1.grafana.status[0].load_balancer[0].ingress) > 0 ? kubernetes_ingress_v1.grafana.status[0].load_balancer[0].ingress[0].hostname : "Load balancer not ready yet"
}

output "internal_alb_dns" {
  description = "Internal ALB DNS name for observability services"
  value       = length(kubernetes_ingress_v1.internal_observability.status) > 0 && length(kubernetes_ingress_v1.internal_observability.status[0].load_balancer) > 0 && length(kubernetes_ingress_v1.internal_observability.status[0].load_balancer[0].ingress) > 0 ? kubernetes_ingress_v1.internal_observability.status[0].load_balancer[0].ingress[0].hostname : "Load balancer not ready yet"
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "https://${var.external_domain_name}"
}

output "alloy_external_endpoint" {
  description = "External endpoint for Alloy via internal ALB"
  value       = "https://${var.internal_domain_name}:9443/alloy"
}

output "loki_external_endpoint" {
  description = "External endpoint for Loki via internal ALB"
  value       = "https://${var.internal_domain_name}:9443/loki"
}

output "tempo_external_endpoint" {
  description = "External endpoint for Tempo via internal ALB"
  value       = "https://${var.internal_domain_name}:9443/tempo"
}

output "pushgateway_external_endpoint" {
  description = "External endpoint for PushGateway via internal ALB"
  value       = "https://${var.internal_domain_name}:9443/pushgateway"
}
