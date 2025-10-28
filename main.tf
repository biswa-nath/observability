# Main Terraform configuration for EKS Observability Stack

# Create observability namespace
resource "kubernetes_namespace" "observability" {
  metadata {
    name = var.observability_namespace
    labels = {
      name = var.observability_namespace
    }
  }
}

# Modules
module "storage" {
  source = "./modules/storage"
  
  cluster_name             = var.cluster_name
  observability_namespace  = var.observability_namespace
  tags                    = var.tags
  
  depends_on = [kubernetes_namespace.observability]
}

module "prometheus" {
  source = "./modules/prometheus"
  
  cluster_name            = var.cluster_name
  observability_namespace = var.observability_namespace
  storage_class_name     = var.storage_class_name
  s3_bucket_name         = module.storage.s3_bucket_name
  storage_config         = var.storage_config
  
  depends_on = [module.storage]
}

module "grafana" {
  source = "./modules/grafana"
  
  cluster_name            = var.cluster_name
  observability_namespace = var.observability_namespace
  domain_name            = var.external_domain_name
  storage_config         = var.storage_config
  
  depends_on = [module.prometheus]
}

module "loki" {
  source = "./modules/loki"
  
  cluster_name            = var.cluster_name
  observability_namespace = var.observability_namespace
  s3_bucket_name         = module.storage.s3_bucket_name
  storage_config         = var.storage_config
  
  depends_on = [module.storage]
}

module "tempo" {
  source = "./modules/tempo"
  
  cluster_name            = var.cluster_name
  observability_namespace = var.observability_namespace
  s3_bucket_name         = module.storage.s3_bucket_name
  storage_config         = var.storage_config
  
  depends_on = [module.storage]
}

module "alloy" {
  source = "./modules/alloy"
  
  cluster_name            = var.cluster_name
  observability_namespace = var.observability_namespace
  
  depends_on = [module.prometheus, module.loki, module.tempo]
}

module "ingress" {
  source = "./modules/ingress"
  
  cluster_name           = var.cluster_name
  observability_namespace = var.observability_namespace
  external_domain_name   = var.external_domain_name
  internal_domain_name   = var.internal_domain_name
  external_domain_for_acm = var.external_domain_for_acm
  internal_domain_for_acm = var.internal_domain_for_acm
  
  depends_on = [module.alloy, module.loki, module.tempo, module.prometheus, module.grafana]
}
