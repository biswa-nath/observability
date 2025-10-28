# EKS Observability Stack

A comprehensive observability solution hosted on Amazon EKS cluster featuring Prometheus, Grafana, Loki, Tempo, and Grafana Alloy with OpenTelemetry support.

## Architecture

- **Prometheus**: Metrics collection with AlertManager and PushGateway
- **Grafana**: Visualization dashboard with external HTTPS access via AWS Load Balancer Controller
- **Loki**: Log aggregation with S3 TSDB storage
- **Tempo**: Distributed tracing with S3 storage
- **Grafana Alloy**: OpenTelemetry collector for metrics, logs, and traces
- **Storage**: EFS for persistent storage with separate directories, S3 for long-term data retention
- **Security**: Auto-generated Grafana password stored in AWS Systems Manager Parameter Store

## Prerequisites

1. Existing EKS cluster with AWS Load Balancer Controller installed
2. EFS CSI driver installed on the cluster
3. **Existing EFS file system** for persistent storage
4. ACM certificates for both external and internal domains
5. Domain names configured to point to the load balancers

## Deployment

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update `terraform.tfvars` with your values:
   - `cluster_name`: Your EKS cluster name
   - `external_domain_name`: Domain for external Grafana access
   - `internal_domain_name`: Domain for internal observability services
   - `storage_config`: Customize storage sizes (default: 60Gi total EFS)

3. Initialize and deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Troubleshooting

### AWS Load Balancer Controller Webhook Issues

If you encounter webhook timeout errors during deployment:

```
Error: failed calling webhook "mservice.elbv2.k8s.aws": context deadline exceeded
```

**Fix**:
1. Temporarily disable webhooks:
   ```bash
   kubectl delete validatingwebhookconfiguration aws-load-balancer-webhook
   kubectl delete mutatingwebhookconfiguration aws-load-balancer-webhook
   ```

2. Run terraform apply:
   ```bash
   terraform apply
   ```

3. Restore webhooks:
   ```bash
   kubectl rollout restart deployment/aws-load-balancer-controller -n kube-system
   ```

## Access

- **Grafana**: https://your-external-domain.com
- **Admin Password**: Retrieved from SSM Parameter Store (output after deployment)

## Features

### Prometheus
- 30-day retention
- Kubernetes pod discovery
- AlertManager with persistent storage
- PushGateway for batch jobs
- EFS persistent storage with dedicated `/prometheus` directory

### Grafana
- Pre-configured dashboards for Kubernetes monitoring
- HTTPS access via AWS Load Balancer Controller
- Integrated with Prometheus, Loki, and Tempo
- Auto-generated secure password
- EFS storage in `/grafana` directory

### Loki
- S3 TSDB storage for cost-effective log retention
- 31-day retention policy
- Kubernetes log collection via Alloy
- EFS storage for components in `/loki/` subdirectories

### Tempo
- S3 storage for traces
- 30-day retention
- OTLP, Jaeger, and Zipkin protocol support
- EFS storage in `/tempo` directory

### Grafana Alloy
- OpenTelemetry collection (OTLP, Jaeger, Zipkin)
- Kubernetes metrics and logs with advanced processing
- Trace forwarding to Tempo
- Node exporter metrics
- Self-monitoring capabilities

## Storage Configuration

### EFS Directory Structure (Total: 60Gi default)
```
EFS Root/
├── /prometheus     (25Gi - Prometheus metrics)
├── /alertmanager   (5Gi - Alert state)
├── /grafana        (10Gi - Dashboards/config)
├── /loki/
│   ├── /write      (5Gi - Loki write component)
│   ├── /read       (5Gi - Loki read component)
│   └── /backend    (5Gi - Loki backend component)
├── /tempo          (10Gi - Trace cache)
└── /pushgateway    (5Gi - Batch metrics)
```

### Customizable Storage
All storage sizes are configurable via `storage_config` in `terraform.tfvars`:
```hcl
storage_config = {
  prometheus_storage    = "25Gi"
  alertmanager_storage = "5Gi"
  grafana_storage      = "10Gi"
  loki_storage         = "5Gi"   # Per component
  tempo_storage        = "10Gi"
  pushgateway_storage  = "5Gi"
}
```

## Load Balancer Architecture

### Two ALB Setup:
1. **Internet-facing ALB**: Grafana dashboard access (HTTPS on port 443)
2. **Internal ALB**: Observability services access within VPC (HTTPS on port 9443)

### External Domain Endpoints
- **Grafana**: `https://grafana.example.com`

### Internal Domain Endpoints (VPC Access Only)
- **Alloy OTLP**: `https://observability.internal.example.com:9443/alloy`
- **Loki**: `https://observability.internal.example.com:9443/loki`
- **Tempo**: `https://observability.internal.example.com:9443/tempo`
- **PushGateway**: `https://observability.internal.example.com:9443/pushgateway`

### Direct Service Endpoints (Cluster Internal)
- **Alloy OTLP gRPC**: `alloy.observability.svc.cluster.local:4317`
- **Alloy OTLP HTTP**: `http://alloy.observability.svc.cluster.local:4318`
- **PushGateway**: `pushgateway.observability.svc.cluster.local:9091`

## Monitoring External Resources

For monitoring resources outside the EKS cluster but within the AWS VPC:

1. **Use Internal ALB Endpoints** for external VPC applications
2. **Use Direct Service Endpoints** for in-cluster applications
3. **Configure applications** to send telemetry to Alloy endpoints

## Certificate Management

- **Automatic Discovery**: Certificates are automatically discovered by domain name using ACM data sources
- **Two Certificates Required**: One for external domain, one for internal domain
- **Same Region**: Both certificates must be in the same AWS account/region as the EKS cluster

## Cost Optimization

- Uses self-hosted components instead of AWS managed services
- EFS for shared persistent storage with organized directory structure
- S3 for cost-effective long-term storage
- Configurable retention policies
- ReadWriteMany access mode for efficient storage sharing

## Security

- IAM roles with least privilege access
- Encrypted EFS and S3 storage
- HTTPS-only access to all external endpoints
- Secure password generation and storage
- Namespace filtering to exclude system logs

## Module Structure

```
modules/
├── storage/     # EFS, S3, IAM roles
├── prometheus/  # Prometheus, AlertManager, PushGateway
├── grafana/     # Grafana with password management
├── loki/        # Loki distributed setup
├── tempo/       # Tempo tracing
├── alloy/       # OpenTelemetry collector
└── ingress/     # ALB Ingress resources
```
