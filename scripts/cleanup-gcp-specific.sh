#!/bin/bash
set -e

echo "Cleaning up GCP-specific files and references..."

# Remove GCP-specific documentation
rm -rf docs/workload-identity.md 2>/dev/null || true
rm -rf docs/ci-cd-pipeline.md 2>/dev/null || true

# Remove GCP-specific extras
rm -rf extras/cloudsql/ 2>/dev/null || true
rm -rf iac/ 2>/dev/null || true

# Remove GCP-specific workflow files
rm -rf .github/workflows/ci.yaml 2>/dev/null || true
rm -rf .github/workflows/cd.yaml 2>/dev/null || true

# Remove old kubernetes-manifests in favor of new structure
echo "Old kubernetes-manifests directory preserved as kubernetes-manifests-original"
if [ -d "kubernetes-manifests" ]; then
    mv kubernetes-manifests kubernetes-manifests-original
fi

# Remove workload identity annotations from existing manifests
find manifests/ -name "*.yaml" -type f -exec sed -i '/iam\.gke\.io\/gcp-service-account/d' {} \; 2>/dev/null || true
find manifests/ -name "*.yaml" -type f -exec sed -i '/cloud\.google\.com/d' {} \; 2>/dev/null || true

# Update references to GCR in manifests
find manifests/ -name "*.yaml" -type f -exec sed -i 's|gcr\.io/.*@sha256:[a-f0-9]*|IMAGE_PLACEHOLDER|g' {} \; 2>/dev/null || true
find manifests/ -name "*.yaml" -type f -exec sed -i 's|us-central1-docker\.pkg\.dev/.*@sha256:[a-f0-9]*|IMAGE_PLACEHOLDER|g' {} \; 2>/dev/null || true

echo "✅ GCP-specific cleanup completed"
echo ""
echo "Summary of changes:"
echo "- Removed GCP-specific documentation"
echo "- Removed GCP infrastructure code"
echo "- Removed GCP-specific workflows"
echo "- Cleaned up manifest annotations"
echo "- Moved old manifests to kubernetes-manifests-original"
echo ""
echo "New structure is available in manifests/ directory"