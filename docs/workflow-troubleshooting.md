# GitHub Workflows Troubleshooting

This document helps debug common issues with the GitHub Actions workflows.

## 🔧 Available Workflows

### 1. Build and Push Images (`build-and-push.yml`)
- **Python Services**: `frontend`, `userservice`, `contacts`, `loadgenerator`
  - Uses Docker build with multi-platform support (linux/amd64, linux/arm64)
  - Pushes to GitHub Container Registry (ghcr.io)
- **Java Services**: `ledgerwriter`, `balancereader`, `transactionhistory`
  - Uses Maven Jib plugin for containerization
  - Direct push to registry without local Docker daemon

### 2. Test Suite (`test.yml`)
- Python tests using pytest
- Java tests using Maven surefire
- Code linting and formatting checks
- Kubernetes manifest validation

## 🚨 Common Issues and Solutions

### Build Failures

#### Python Services
**Issue**: `requirements.txt not found`
```bash
# Check if requirements.txt exists
find src/ -name "requirements.txt"
```

**Issue**: `Docker build context errors`
```bash
# Test local build
docker build src/frontend -t test-frontend
```

#### Java Services  
**Issue**: `Maven dependency resolution`
```bash
# Test local build
cd src/ledger/ledgerwriter
mvn clean compile
```

**Issue**: `Jib plugin not found`
```bash
# Check if Jib is configured
grep -A 10 "jib-maven-plugin" src/ledger/*/pom.xml
```

### Authentication Issues

**Issue**: `unauthorized: authentication required`
- Ensure `GITHUB_TOKEN` has `packages:write` permission
- Check if repository has Container Registry enabled

**Issue**: `403 Forbidden when pushing`
- Verify the repository setting allows GitHub Actions to write packages
- Check if the image name conflicts with existing packages

### Registry Issues

**Issue**: `registry ghcr.io does not support multiarch images`
- Remove `platforms: linux/amd64,linux/arm64` for testing
- Try single platform build first

### Manifest Validation Failures

**Issue**: `kubeval validation errors`
```bash
# Test manifest validation locally
kustomize build manifests/base | kubeval
```

**Issue**: `kustomize build failures`
```bash
# Check kustomization.yaml syntax
kustomize build manifests/base --dry-run
```

## 🛠️ Local Testing

### Test Python Builds
```bash
# Test each Python service
docker build src/frontend -t test-frontend
docker build src/accounts/userservice -t test-userservice
docker build src/accounts/contacts -t test-contacts  
docker build src/loadgenerator -t test-loadgenerator
```

### Test Java Builds  
```bash
# Test each Java service
cd src/ledger/ledgerwriter
mvn clean compile jib:dockerBuild -Dimage=test-ledgerwriter

cd ../balancereader  
mvn clean compile jib:dockerBuild -Dimage=test-balancereader

cd ../transactionhistory
mvn clean compile jib:dockerBuild -Dimage=test-transactionhistory
```

### Test Kubernetes Manifests
```bash
# Install tools
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
tar xf kubeval-linux-amd64.tar.gz

# Validate manifests
kustomize build manifests/base | kubeval
kustomize build manifests/overlays/development | kubeval
```

## 🔍 Debugging Workflow Runs

### Check Workflow Status
1. Go to repository → Actions tab
2. Look for failed workflows (red X)
3. Click on failed workflow to see logs

### Common Log Patterns
```bash
# Authentication failure
ERROR: denied: permission_denied

# Build context issue  
ERROR: failed to solve: failed to read dockerfile

# Dependency issue
ERROR: Could not resolve dependencies

# Registry issue
ERROR: failed to push to registry
```

### Manual Workflow Trigger
Use the `workflow_dispatch` trigger to test specific services:
1. Go to Actions → Build and Push Images
2. Click "Run workflow"
3. Specify services to build or leave as "all"

## 📋 Workflow Configuration

### Environment Variables
- `REGISTRY`: `ghcr.io` (GitHub Container Registry)
- `IMAGE_PREFIX`: `${{ github.repository }}` (e.g., `owner/repo`)

### Permissions Required
```yaml
permissions:
  contents: read
  packages: write
```

### Conditional Logic
- **Push to registry**: Only on `main`/`develop` branches, not PRs
- **Multi-platform**: Only for Python services (Docker build)
- **Authentication**: Uses `GITHUB_TOKEN` for registry access

## 🎯 Quick Fixes

### Force Rebuild All Images
```bash
# Trigger manual workflow
gh workflow run build-and-push.yml
```

### Skip Problematic Service
Temporarily remove from matrix in workflow:
```yaml
strategy:
  matrix:
    service: [frontend, userservice, contacts]  # removed loadgenerator
```

### Test Without Push
Set `push: false` in Docker build action for testing:
```yaml
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    push: false  # Test build only
```

## 📞 Getting Help

1. Check workflow logs in GitHub Actions
2. Test builds locally using commands above
3. Validate manifests using provided scripts
4. Use `./scripts/validate-workflows.sh` for comprehensive checks