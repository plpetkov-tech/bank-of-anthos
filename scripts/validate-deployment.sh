#!/bin/bash
set -e

NAMESPACE=${1:-bank-of-anthos}
TIMEOUT=${2:-300}

echo "Validating Bank of Anthos deployment in namespace: $NAMESPACE"

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "Namespace $NAMESPACE does not exist. Creating it..."
    kubectl create namespace "$NAMESPACE"
fi

# Check pods are running
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l application=bank-of-anthos -n "$NAMESPACE" --timeout="${TIMEOUT}s" || {
    echo "Some pods are not ready. Current status:"
    kubectl get pods -l application=bank-of-anthos -n "$NAMESPACE"
    exit 1
}

# Check services are accessible
echo "Checking services..."
kubectl get svc -n "$NAMESPACE"

# Test frontend endpoint
echo "Testing frontend health..."
if kubectl get svc frontend -n "$NAMESPACE" &> /dev/null; then
    # Try port-forward to test the service
    kubectl port-forward svc/frontend 8080:80 -n "$NAMESPACE" &
    PF_PID=$!
    sleep 5
    
    if curl -f http://localhost:8080/ready &> /dev/null; then
        echo "✅ Frontend health check passed"
    else
        echo "❌ Frontend health check failed"
        kill $PF_PID
        exit 1
    fi
    
    kill $PF_PID
else
    echo "❌ Frontend service not found"
    exit 1
fi

# Check ConfigMaps
echo "Checking configuration..."
if kubectl get configmap bank-of-anthos-config -n "$NAMESPACE" &> /dev/null; then
    echo "✅ ConfigMap found"
else
    echo "❌ ConfigMap not found"
    exit 1
fi

# Check Secrets
echo "Checking secrets..."
if kubectl get secret database-credentials -n "$NAMESPACE" &> /dev/null; then
    echo "✅ Database credentials secret found"
else
    echo "❌ Database credentials secret not found"
    exit 1
fi

echo "🎉 Deployment validation completed successfully!"
echo ""
echo "To access the application:"
echo "kubectl port-forward svc/frontend 8080:80 -n $NAMESPACE"
echo "Then open http://localhost:8080"