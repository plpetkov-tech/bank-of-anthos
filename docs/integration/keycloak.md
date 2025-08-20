# Integrating with Keycloak

This guide shows how to integrate Bank of Anthos with an existing Keycloak instance.

## Prerequisites
- Keycloak instance running in your cluster
- Realm configured for Bank of Anthos

## Configuration

### 1. Create OIDC client in Keycloak
1. Login to Keycloak admin console
2. Navigate to your realm
3. Go to Clients > Create
4. Set Client ID: `bank-of-anthos`
5. Set Client Protocol: `openid-connect`
6. Set Access Type: `confidential`
7. Set Valid Redirect URIs: `https://your-bank-domain.com/login`

### 2. Update ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: bank-of-anthos-config
data:
  AUTH_ENABLED: "true"
  AUTH_TYPE: "oidc"
  OIDC_ISSUER: "https://keycloak.auth.svc.cluster.local/auth/realms/bank"
  OIDC_CLIENT_ID: "bank-of-anthos"
  OIDC_SCOPE: "openid profile email"
```

### 3. Create Secret with client credentials
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: oidc-secret
type: Opaque
stringData:
  OIDC_CLIENT_SECRET: "your-client-secret-from-keycloak"
```

### 4. Apply the configuration
```bash
kubectl apply -f manifests/optional/auth/oidc-config.yaml
kubectl patch secret oidc-secret --patch='{"stringData":{"OIDC_CLIENT_SECRET":"actual-secret"}}'
```

## Testing
1. Access the frontend URL
2. You should be redirected to Keycloak login
3. After successful login, you'll be redirected back to Bank of Anthos