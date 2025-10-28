variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "storage_class_name" {
  description = "Name of the existing EFS storage class"
  type        = string
  default     = "efs-sc"
}

variable "observability_namespace" {
  description = "Kubernetes namespace for observability components"
  type        = string
  default     = "monitoring"
}

variable "external_domain_name" {
  description = "Domain name for external Grafana HTTPS endpoint"
  type        = string
}

variable "internal_domain_name" {
  description = "Domain name for internal observability services HTTPS endpoint"
  type        = string
}

variable "external_domain_for_acm" {
  description = "Domain name for external acm certificate"
  type        = string
}

variable "internal_domain_for_acm" {
  description = "Domain name for internal acm certificate"
  type        = string
}

variable "storage_config" {
  description = "Storage configuration for observability components"
  type = object({
    prometheus_storage    = optional(string, "25Gi")
    alertmanager_storage = optional(string, "5Gi")
    grafana_storage      = optional(string, "10Gi")
    loki_storage         = optional(string, "5Gi")
    tempo_storage        = optional(string, "10Gi")
    pushgateway_storage  = optional(string, "5Gi")
  })
  default = {
    prometheus_storage    = "25Gi"
    alertmanager_storage = "5Gi"
    grafana_storage      = "10Gi"
    loki_storage         = "5Gi"
    tempo_storage        = "10Gi"
    pushgateway_storage  = "5Gi"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "observability"
    ManagedBy   = "terraform"
  }
}
