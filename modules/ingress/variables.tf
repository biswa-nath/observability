variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "observability_namespace" {
  description = "Kubernetes namespace for observability components"
  type        = string
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
