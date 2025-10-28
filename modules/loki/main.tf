# Loki module with S3 TSDB storage using templates
resource "kubernetes_service_account" "loki" {
  metadata {
    name      = "loki-sa"
    namespace = var.observability_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.observability.arn
    }
  }
}

data "aws_iam_role" "observability" {
  name = "${var.cluster_name}-observability-role"
}

data "aws_region" "current" {}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.41.4"
  namespace  = var.observability_namespace
  timeout    = 600  # 10 minutes
  
  values = [
    templatefile("${path.module}/templates/loki-values.yaml", {
      service_account_name     = kubernetes_service_account.loki.metadata[0].name
      s3_bucket_name          = var.s3_bucket_name
      aws_region              = data.aws_region.current.name
      storage_class_name      = "efs-sc"
      observability_namespace = var.observability_namespace
      loki_storage           = var.storage_config.loki_storage
    })
  ]
  
  depends_on = [kubernetes_service_account.loki]
}
