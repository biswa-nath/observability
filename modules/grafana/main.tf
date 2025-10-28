# Grafana module with AWS Load Balancer Controller and Ingress using templates
resource "kubernetes_service_account" "grafana" {
  metadata {
    name      = "grafana-sa"
    namespace = var.observability_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.observability.arn
    }
  }
}

data "aws_iam_role" "observability" {
  name = "${var.cluster_name}-observability-role"
}

# Generate Grafana admin password
resource "random_password" "grafana_admin" {
  length  = 16
  special = true
}

# Store password in SSM Parameter Store
resource "aws_ssm_parameter" "grafana_password" {
  name  = "/observability/${var.cluster_name}/grafana/admin-password"
  type  = "SecureString"
  value = random_password.grafana_admin.result
  
  tags = {
    Environment = "observability"
    ManagedBy   = "terraform"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.0.19"
  namespace  = var.observability_namespace
  timeout    = 600  # 10 minutes
  
  values = [
    templatefile("${path.module}/templates/grafana-values.yaml", {
      service_account_name     = kubernetes_service_account.grafana.metadata[0].name
      admin_password          = random_password.grafana_admin.result
      observability_namespace = var.observability_namespace
      domain_name            = var.domain_name
      grafana_storage        = var.storage_config.grafana_storage
    })
  ]
  
  depends_on = [kubernetes_service_account.grafana]
}
