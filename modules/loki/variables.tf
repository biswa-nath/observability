variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "observability_namespace" {
  description = "Kubernetes namespace for observability components"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Loki storage"
  type        = string
}

variable "storage_config" {
  description = "Storage configuration for observability components"
  type = object({
    prometheus_storage    = string
    alertmanager_storage = string
    grafana_storage      = string
    loki_storage         = string
    tempo_storage        = string
    pushgateway_storage  = string
  })
}
