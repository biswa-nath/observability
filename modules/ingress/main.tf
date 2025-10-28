# Data sources to find ACM certificates by domain names
data "aws_acm_certificate" "external" {
  domain   = var.external_domain_for_acm
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "internal" {
  domain   = var.internal_domain_for_acm
  statuses = ["ISSUED"]
}

# Get EKS cluster info to find VPC
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

# Find public subnets for internet-facing ALB
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.cluster.vpc_config[0].vpc_id]
  }
  
  tags = {
    Name = "*public*"
  }
}

# Find private subnets for internal ALB
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.cluster.vpc_config[0].vpc_id]
  }
  
  tags = {
    Name = "*private*"
  }
}

# Internet-facing ALB Ingress for Grafana
resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana-ingress"
    namespace = var.observability_namespace
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = data.aws_acm_certificate.external.arn
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/api/health"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/tags"                 = "Environment=observability,ManagedBy=terraform"
      "alb.ingress.kubernetes.io/subnets"              = join(",", data.aws_subnets.public.ids)
    }
  }
  
  spec {
    ingress_class_name = "alb"
    rule {
      host = var.external_domain_name
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Internal ALB Ingress for observability services with path-based routing
resource "kubernetes_ingress_v1" "internal_observability" {
  metadata {
    name      = "internal-observability-ingress"
    namespace = var.observability_namespace
    annotations = {
      "kubernetes.io/ingress.class"              = "alb"
      "alb.ingress.kubernetes.io/scheme"         = "internal"
      "alb.ingress.kubernetes.io/target-type"    = "ip"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.internal.arn
      "alb.ingress.kubernetes.io/listen-ports"   = "[{\"HTTPS\": 9443}]"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/tags"           = "Environment=observability,ManagedBy=terraform"
      "alb.ingress.kubernetes.io/subnets"        = join(",", data.aws_subnets.private.ids)
    }
  }
  
  spec {
    ingress_class_name = "alb"
    rule {
      host = var.internal_domain_name
      http {
        path {
          path      = "/alloy/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "alloy"
              port {
                number = 12345
              }
            }
          }
        }
        path {
          path      = "/loki/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "loki-gateway"
              port {
                number = 80
              }
            }
          }
        }
        path {
          path      = "/tempo/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "tempo"
              port {
                number = 4318
              }
            }
          }
        }
        path {
          path      = "/pushgateway/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "pushgateway-prometheus-pushgateway"
              port {
                number = 9091
              }
            }
          }
        }
        path {
          path      = "/otlp/v1/traces"
          path_type = "Exact"
          backend {
            service {
              name = "tempo"
              port {
                number = 4318
              }
            }
          }
        }
        path {
          path      = "/v1/push"
          path_type = "Exact"
          backend {
            service {
              name = "loki-gateway"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
