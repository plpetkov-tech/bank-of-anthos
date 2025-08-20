#!/bin/bash
set -e

DEPLOYMENT_TYPE=${1:-minimal}
NAMESPACE="bank-of-anthos-${DEPLOYMENT_TYPE}"

echo "🚀 Quick deploying Bank of Anthos ($DEPLOYMENT_TYPE)"

case "$DEPLOYMENT_TYPE" in
    minimal)
        echo "Deploying minimal setup (in-memory, no auth)..."
        kubectl apply -k manifests/examples/minimal
        ;;
    homelab)
        echo "Deploying homelab setup (with monitoring and ingress)..."
        kubectl apply -k manifests/examples/homelab
        ;;
    development)
        echo "Deploying development setup..."
        kubectl apply -k manifests/overlays/development
        ;;
    production)
        echo "Deploying production setup..."
        echo "⚠️  Make sure to update database credentials and OIDC secrets!"
        kubectl apply -k manifests/overlays/production
        ;;
    *)
        echo "Usage: $0 [minimal|homelab|development|production]"
        echo ""
        echo "Deployment types:"
        echo "  minimal     - In-memory, no auth, single replica"
        echo "  homelab     - With monitoring and ingress"
        echo "  development - Debug mode, metrics enabled"
        echo "  production  - Full production setup"
        exit 1
        ;;
esac

echo ""
echo "⏳ Waiting for deployment to be ready..."
sleep 5

# Run validation
./scripts/validate-deployment.sh "$NAMESPACE"

echo ""
echo "🎉 Quick deployment completed!"
echo ""
echo "Next steps:"
case "$DEPLOYMENT_TYPE" in
    minimal)
        echo "- kubectl port-forward svc/frontend 8080:80 -n $NAMESPACE"
        echo "- Open http://localhost:8080"
        ;;
    homelab)
        echo "- Update DNS to point bank.homelab.local to your ingress"
        echo "- Or use: kubectl port-forward svc/frontend 8080:80 -n $NAMESPACE"
        ;;
    development)
        echo "- kubectl port-forward svc/frontend 8080:80 -n $NAMESPACE"
        echo "- Check metrics at http://localhost:8080/metrics"
        ;;
    production)
        echo "- Configure external database secrets"
        echo "- Configure OIDC authentication"
        echo "- Set up proper ingress with TLS"
        ;;
esac