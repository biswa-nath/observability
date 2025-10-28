# Prometheus module with AlertManager and PushGateway using templates
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus-sa"
    namespace = var.observability_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.observability.arn
    }
  }
}

data "aws_iam_role" "observability" {
  name = "${var.cluster_name}-observability-role"
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.0"
  namespace  = var.observability_namespace
  
  values = [
    templatefile("${path.module}/templates/prometheus-values.yaml", {
      service_account_name     = kubernetes_service_account.prometheus.metadata[0].name
      storage_class_name      = var.storage_class_name
      observability_namespace = var.observability_namespace
      prometheus_storage      = var.storage_config.prometheus_storage
      alertmanager_storage    = var.storage_config.alertmanager_storage
    })
  ]
  
  depends_on = [kubernetes_service_account.prometheus]
}

resource "helm_release" "pushgateway" {
  name       = "pushgateway"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-pushgateway"
  version    = "2.4.2"
  namespace  = var.observability_namespace
  
  values = [
    templatefile("${path.module}/templates/pushgateway-values.yaml", {
      service_account_name = kubernetes_service_account.prometheus.metadata[0].name
      storage_class_name  = var.storage_class_name
      pushgateway_storage = var.storage_config.pushgateway_storage
    })
  ]
  
  depends_on = [helm_release.prometheus]
}
