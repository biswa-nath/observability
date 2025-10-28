# Grafana Alloy module for OpenTelemetry collection using templates
resource "kubernetes_service_account" "alloy" {
  metadata {
    name      = "alloy-sa"
    namespace = var.observability_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.observability.arn
    }
  }
}

data "aws_iam_role" "observability" {
  name = "${var.cluster_name}-observability-role"
}

resource "helm_release" "alloy" {
  name       = "alloy"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "0.2.0"
  namespace  = var.observability_namespace
  
  values = [
    templatefile("${path.module}/templates/alloy-values.yaml", {
      service_account_name     = kubernetes_service_account.alloy.metadata[0].name
      observability_namespace = var.observability_namespace
    })
  ]
  
  depends_on = [kubernetes_service_account.alloy]
}

# ConfigMap for Alloy configuration
resource "kubernetes_config_map" "alloy_config" {
  metadata {
    name      = "alloy-config"
    namespace = var.observability_namespace
  }
  
  data = {
    "config.alloy" = templatefile("${path.module}/templates/alloy-config.alloy", {
      observability_namespace = var.observability_namespace
      cluster_name           = var.cluster_name
    })
  }
}
