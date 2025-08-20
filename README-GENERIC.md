# Bank of Anthos - Generic Kubernetes Application

Bank of Anthos is a sample HTTP-based web application that simulates a bank's payment processing network. It's designed to be a cloud-agnostic, generic Kubernetes application that can run on any Kubernetes cluster with any GitOps tool.

## ✨ Features

- **Cloud Agnostic**: Runs on any Kubernetes cluster (GKE, EKS, AKS, self-managed)
- **Configurable Authentication**: Support for no auth, basic auth, or OIDC
- **Optional Observability**: Prometheus metrics and OpenTelemetry tracing
- **Modular Deployments**: Multiple deployment scenarios with Kustomize
- **GitOps Ready**: Works with ArgoCD, Flux, and other GitOps tools

## 🏗️ Architecture

```
Frontend (Python/Flask) → Backend Services (Java/Spring Boot) → Databases (PostgreSQL)
                              ↓
                   - User Service (Account management)
                   - Contacts Service (Contact management)  
                   - Transaction History (Read transactions)
                   - Balance Reader (Read balances)
                   - Ledger Writer (Write transactions)
```

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (1.19+)
- kubectl configured
- (Optional) kustomize CLI

### Option 1: Minimal Deployment (In-Memory)
Perfect for testing and demos:
```bash
kubectl apply -k manifests/examples/minimal
```

### Option 2: Quick Deploy Script
```bash
# Clone the repository
git clone <repository-url>
cd bank-of-anthos

# Deploy minimal setup
./scripts/quick-deploy.sh minimal

# Or deploy homelab setup with monitoring
./scripts/quick-deploy.sh homelab
```

### Option 3: Development Setup
```bash
kubectl apply -k manifests/overlays/development
```

Access the application:
```bash
kubectl port-forward svc/frontend 8080:80
# Open http://localhost:8080
```

## 📁 Repository Structure

```
manifests/
├── base/                    # Base Kubernetes manifests
│   ├── deployments/         # Application deployments
│   ├── services/           # Kubernetes services
│   ├── configmaps/         # Configuration
│   ├── secrets/            # Secret templates
│   └── databases/          # Database manifests
├── overlays/               # Environment-specific configurations
│   ├── development/        # Development settings
│   ├── staging/           # Staging settings
│   └── production/        # Production settings
├── optional/              # Optional components
│   ├── ingress/           # Ingress controllers (NGINX, Istio)
│   ├── monitoring/        # Prometheus ServiceMonitors
│   └── auth/              # OIDC authentication
└── examples/              # Example deployments
    ├── minimal/           # Minimal in-memory setup
    ├── homelab/          # Homelab with monitoring
    └── production/       # Production example

src/                       # Application source code
├── frontend/             # Python Flask frontend
├── accounts/             # Account management services
├── ledger/              # Ledger services (Java)
└── loadgenerator/       # Load testing tool

docs/                     # Documentation
├── configuration.md     # Configuration reference
├── deployment-guide.md  # Detailed deployment guide
└── integration/         # Integration guides
    └── keycloak.md      # Keycloak OIDC integration

scripts/                  # Utility scripts
├── quick-deploy.sh      # Quick deployment script
├── validate-deployment.sh # Deployment validation
└── cleanup-gcp-specific.sh # Remove GCP dependencies
```

## 🔧 Configuration

### Environment Variables
The application uses a central ConfigMap for configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: bank-of-anthos-config
data:
  # Application
  BANK_NAME: "Bank of Anthos"
  LOG_LEVEL: "INFO"
  
  # Authentication
  AUTH_ENABLED: "false"
  AUTH_TYPE: "none"  # none, basic, oidc
  
  # Observability  
  METRICS_ENABLED: "false"
  TRACING_ENABLED: "false"
  
  # Database
  DB_HOST: "postgresql.database.svc.cluster.local"
  DB_PORT: "5432"
```

### Database Configuration
For external databases, update the secret:
```bash
kubectl create secret generic database-credentials \
  --from-literal=accounts_db_uri="postgresql://user:pass@external-db:5432/accounts" \
  --from-literal=ledger_db_uri="postgresql://user:pass@external-db:5432/ledger"
```

## 🎯 Deployment Scenarios

### 1. Minimal (In-Memory)
- No external dependencies
- In-memory data storage
- Single replica
- Perfect for demos

```bash
kubectl apply -k manifests/examples/minimal
```

### 2. Homelab
- Include monitoring (Prometheus)
- NGINX Ingress
- Local domain (bank.homelab.local)

```bash
kubectl apply -k manifests/examples/homelab
```

### 3. Development
- Debug logging
- Metrics enabled
- Single replicas
- In-cluster databases

```bash
kubectl apply -k manifests/overlays/development
```

### 4. Production
- Multiple replicas
- External databases
- OIDC authentication
- Full observability
- TLS ingress

```bash
kubectl apply -k manifests/overlays/production
```

## 🔐 Authentication Options

### No Authentication (Default)
```yaml
AUTH_ENABLED: "false"
```

### OIDC (Keycloak, Auth0, etc.)
```yaml
AUTH_ENABLED: "true"
AUTH_TYPE: "oidc"
OIDC_ISSUER: "https://your-oidc-provider/auth/realms/bank"
OIDC_CLIENT_ID: "bank-of-anthos"
```

See [Keycloak Integration Guide](docs/integration/keycloak.md) for details.

## 📊 Observability

### Prometheus Metrics
Enable metrics collection:
```yaml
METRICS_ENABLED: "true"
```

Deploy ServiceMonitor:
```bash
kubectl apply -f manifests/optional/monitoring/servicemonitor.yaml
```

### Distributed Tracing
Enable tracing:
```yaml
TRACING_ENABLED: "true"
```

Configure your tracing backend (Jaeger, Zipkin, etc.) endpoint.

## 🌐 Ingress Options

### NGINX Ingress
```bash
kubectl apply -f manifests/optional/ingress/nginx-ingress.yaml
```

### Istio Gateway
```bash
kubectl apply -f manifests/optional/ingress/istio-gateway.yaml
```

## 🛠️ Development

### Using Skaffold
```bash
# Development with auto-reload
skaffold dev -f skaffold-generic.yaml

# Build and deploy
skaffold run -f skaffold-generic.yaml
```

### Build Images
```bash
# Python services
docker build -t frontend src/frontend/

# Java services (using Maven)
cd src/ledger/ledgerwriter
mvn spring-boot:build-image
```

## 🧪 Testing

### Validation
```bash
./scripts/validate-deployment.sh [namespace]
```

### Load Testing
```bash
kubectl apply -f src/loadgenerator/
```

## 📖 Documentation

- [Configuration Reference](docs/configuration.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Keycloak Integration](docs/integration/keycloak.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with multiple deployment scenarios
5. Submit a pull request

## 📝 License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## 🆘 Support

- [Issues](../../issues)
- [Documentation](docs/)
- [Configuration Reference](docs/configuration.md)

---

**Note**: This is a generic, cloud-agnostic version of Bank of Anthos. The original Google Cloud-specific version is available in the [kubernetes-manifests-original](kubernetes-manifests-original/) directory.