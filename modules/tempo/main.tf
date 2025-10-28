# Tempo module with S3 storage using templates
resource "kubernetes_service_account" "tempo" {
  metadata {
    name      = "observability-sa"
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

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.7.1"
  namespace  = var.observability_namespace
  timeout    = 600  # 10 minutes
  
  values = [
    templatefile("${path.module}/templates/tempo-values.yaml", {
      service_account_name     = kubernetes_service_account.tempo.metadata[0].name
      s3_bucket_name          = var.s3_bucket_name
      aws_region              = data.aws_region.current.name
      storage_class_name      = "efs-sc"
      observability_namespace = var.observability_namespace
      tempo_storage          = var.storage_config.tempo_storage
    })
  ]
  
  depends_on = [kubernetes_service_account.tempo]
}
