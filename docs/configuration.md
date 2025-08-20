# Configuration Reference

## Environment Variables

### Database Configuration
- `DB_HOST`: Database hostname (default: accounts-db/ledger-db)
- `DB_PORT`: Database port (default: 5432)
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database username
- `POSTGRES_PASSWORD`: Database password

### Authentication Configuration
- `AUTH_ENABLED`: Enable authentication (true/false)
- `AUTH_TYPE`: Authentication type (none, basic, oidc)
- `JWT_SECRET`: JWT signing secret
- `JWT_ALGORITHM`: JWT algorithm (HS256, RS256)
- `OIDC_ISSUER`: OIDC provider issuer URL
- `OIDC_CLIENT_ID`: OIDC client ID
- `OIDC_CLIENT_SECRET`: OIDC client secret
- `OIDC_SCOPE`: OIDC scopes (default: "openid profile email")

### Observability Configuration
- `METRICS_ENABLED`: Enable Prometheus metrics (true/false)
- `TRACING_ENABLED`: Enable distributed tracing (true/false)
- `LOG_LEVEL`: Logging level (DEBUG, INFO, WARN, ERROR)
- `LOGGING_PATTERN`: Log pattern format

### Application Configuration
- `BANK_NAME`: Name displayed in the UI (default: "Bank of Anthos")
- `ENV_PLATFORM`: Platform identifier (kubernetes, local, etc.)
- `VERSION`: Application version
- `PORT`: Application port (default: 8080)
- `SCHEME`: HTTP scheme (http/https)

## ConfigMap Structure

The main configuration is stored in the `bank-of-anthos-config` ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: bank-of-anthos-config
data:
  # Database Configuration
  POSTGRES_DB: "bankofanthos"
  POSTGRES_USER: "bankuser"
  DB_HOST: "postgresql.database.svc.cluster.local"
  DB_PORT: "5432"
  
  # Authentication Configuration
  AUTH_ENABLED: "false"
  AUTH_TYPE: "none"
  JWT_SECRET: "your-jwt-secret-here"
  JWT_ALGORITHM: "HS256"
  
  # Observability Configuration
  METRICS_ENABLED: "false"
  TRACING_ENABLED: "false"
  LOG_LEVEL: "INFO"
  
  # Application Configuration
  BANK_NAME: "Bank of Anthos"
  ENV_PLATFORM: "kubernetes"
```

## Secret Management

Sensitive configuration is stored in Kubernetes Secrets:

### Database Credentials
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
type: Opaque
stringData:
  accounts_db_uri: "postgresql://username:password@host:port/database"
  ledger_db_uri: "postgresql://username:password@host:port/database"
```

### JWT Keys
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: jwt-secret
type: Opaque
data:
  jwtRS256.key: <base64-encoded-private-key>
  jwtRS256.key.pub: <base64-encoded-public-key>
```

## Deployment Configurations

### Development
- `LOG_LEVEL=DEBUG`
- `METRICS_ENABLED=true`
- `AUTH_ENABLED=false`
- Reduced resource limits
- Single replica

### Production
- `LOG_LEVEL=INFO`
- `METRICS_ENABLED=true`
- `TRACING_ENABLED=true`
- `AUTH_ENABLED=true`
- Higher resource limits
- Multiple replicas
- External databases

### Minimal
- `DB_TYPE=memory`
- `AUTH_ENABLED=false`
- `METRICS_ENABLED=false`
- No database dependencies