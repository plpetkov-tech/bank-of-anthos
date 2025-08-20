#!/bin/bash
set -e

echo "🔍 Validating GitHub workflows..."

# Check YAML syntax
for workflow in .github/workflows/*.yml .github/workflows/*.yaml; do
    if [ -f "$workflow" ]; then
        echo "Validating $workflow..."
        python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null && echo "  ✅ YAML syntax valid" || echo "  ❌ YAML syntax invalid"
    fi
done

echo ""
echo "🐳 Validating Docker contexts..."

# Check if all service paths have Dockerfiles (for Python services)
python_services=("frontend" "userservice" "contacts" "loadgenerator")
for service in "${python_services[@]}"; do
    case "$service" in
        frontend) path="src/frontend" ;;
        userservice) path="src/accounts/userservice" ;;
        contacts) path="src/accounts/contacts" ;;
        loadgenerator) path="src/loadgenerator" ;;
    esac
    
    if [ -f "$path/Dockerfile" ]; then
        echo "  ✅ $service: Dockerfile exists at $path"
    else
        echo "  ❌ $service: Dockerfile missing at $path"
    fi
    
    if [ -f "$path/requirements.txt" ]; then
        echo "  ✅ $service: requirements.txt exists"
    else
        echo "  ❌ $service: requirements.txt missing"
    fi
done

echo ""
echo "☕ Validating Java service configurations..."

# Check Java services have pom.xml with Jib plugin
java_services=("ledgerwriter" "balancereader" "transactionhistory")
for service in "${java_services[@]}"; do
    path="src/ledger/$service"
    
    if [ -f "$path/pom.xml" ]; then
        echo "  ✅ $service: pom.xml exists at $path"
        if grep -q "jib-maven-plugin" "$path/pom.xml"; then
            echo "  ✅ $service: Jib plugin configured"
        else
            echo "  ❌ $service: Jib plugin missing in pom.xml"
        fi
    else
        echo "  ❌ $service: pom.xml missing at $path"
    fi
done

echo ""
echo "📦 Summary:"
echo "  - Python services: Use Docker build with Dockerfiles"
echo "  - Java services: Use Maven Jib plugin for container builds"
echo "  - All services should be able to build container images"
echo ""
echo "🎯 To test locally:"
echo "  Python: docker build src/frontend -t test-frontend"  
echo "  Java:   cd src/ledger/ledgerwriter && mvn compile jib:dockerBuild"