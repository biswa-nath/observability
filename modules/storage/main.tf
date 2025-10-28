# Storage module - S3 for observability components

# S3 bucket for Loki and Tempo storage
resource "aws_s3_bucket" "observability" {
  bucket = "${var.cluster_name}-observability-s3"
  
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "observability" {
  bucket = aws_s3_bucket.observability.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "observability" {
  bucket = aws_s3_bucket.observability.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "observability" {
  bucket = aws_s3_bucket.observability.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for observability components to access S3
resource "aws_iam_role" "observability" {
  name = "${var.cluster_name}-observability-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:${var.observability_namespace}:observability-sa"
            "${replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  
  tags = var.tags
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_iam_role_policy" "observability_s3" {
  name = "${var.cluster_name}-observability-s3-policy"
  role = aws_iam_role.observability.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.observability.arn,
          "${aws_s3_bucket.observability.arn}/*"
        ]
      }
    ]
  })
}
