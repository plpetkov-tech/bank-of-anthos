# Deployment Guide

## Quick Start

### Prerequisites
- Kubernetes cluster (1.19+)
- kubectl configured
- kustomize (optional, kubectl has built-in support)

### Basic Deployment
```bash
# Deploy with default configuration
kubectl apply -k manifests/base

# Check deployment status
kubectl get pods -l application=bank-of-anthos
```

## Environment-Specific Deployments

### Development
```bash
kubectl apply -k manifests/overlays/development
```

Features:
- Debug logging enabled
- Metrics collection enabled
- Single replica for each service
- Reduced resource limits

### Production
```bash
kubectl apply -k manifests/overlays/production
```

Features:
- Production logging levels
- Full observability stack
- OIDC authentication enabled
- Multiple replicas
- Higher resource limits
- External database configuration

## Example Deployments

### Minimal Setup (In-Memory)
Perfect for testing and demos:
```bash
kubectl apply -k manifests/examples/minimal
```

### Homelab Setup
Includes monitoring and ingress:
```bash
kubectl apply -k manifests/examples/homelab
```

### Production Example
Full-featured production setup:
```bash
kubectl apply -k manifests/examples/production
```

## Optional Components

### Enable Ingress (NGINX)
```bash
kubectl apply -f manifests/optional/ingress/nginx-ingress.yaml
```

### Enable Ingress (Istio)
```bash
kubectl apply -f manifests/optional/ingress/istio-gateway.yaml
```

### Enable Monitoring
```bash
kubectl apply -f manifests/optional/monitoring/servicemonitor.yaml
```

### Enable OIDC Authentication
```bash
kubectl apply -f manifests/optional/auth/oidc-config.yaml
```

## Configuration

### Using External Database
Update the database credentials secret:
```bash
kubectl create secret generic database-credentials \
  --from-literal=accounts_db_uri="postgresql://user:pass@external-db:5432/accounts" \
  --from-literal=ledger_db_uri="postgresql://user:pass@external-db:5432/ledger"
```

### Custom Configuration
Create a custom overlay:
```yaml
# my-config/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- ../manifests/base

configMapGenerator:
- name: bank-of-anthos-config
  behavior: merge
  literals:
  - BANK_NAME=My Custom Bank
  - LOG_LEVEL=DEBUG
  - METRICS_ENABLED=true
```

Apply with:
```bash
kubectl apply -k my-config/
```

## Validation

Check that all pods are running:
```bash
kubectl get pods -l application=bank-of-anthos
```

Test the frontend:
```bash
kubectl port-forward svc/frontend 8080:80
curl http://localhost:8080/ready
```

## Troubleshooting

### Common Issues

#### Pods not starting
Check logs:
```bash
kubectl logs -l app=frontend
```

#### Database connection issues
Verify secrets:
```bash
kubectl get secret database-credentials -o yaml
```

#### Authentication not working
Check OIDC configuration:
```bash
kubectl get configmap oidc-config -o yaml
kubectl get secret oidc-secret -o yaml
```

### Health Checks
All services expose health endpoints:
- `/ready` - Readiness probe
- `/metrics` - Prometheus metrics (if enabled)

## Scaling

Scale individual services:
```bash
kubectl scale deployment frontend --replicas=3
```

Or use HPA:
```bash
kubectl autoscale deployment frontend --cpu-percent=50 --min=1 --max=10
```