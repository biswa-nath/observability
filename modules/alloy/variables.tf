variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "observability_namespace" {
  description = "Kubernetes namespace for observability components"
  type        = string
}
