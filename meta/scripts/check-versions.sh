#!/bin/bash
# Version Compatibility Checker
# Validates versions across all layers match the compatibility matrix

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "Version Compatibility Check"
echo "=========================================="

echo ""
echo "## Expected Versions (from versions.yaml)"
echo ""

# Parse versions.yaml for expected versions
if [ -f "$META_DIR/versions.yaml" ]; then
    echo "Platform Version: $(grep 'platform_version:' "$META_DIR/versions.yaml" | cut -d'"' -f2)"
    echo ""
else
    echo "ERROR: versions.yaml not found"
    exit 1
fi

echo "## Actual Versions"
echo ""

# Kubernetes
echo "### Kubernetes"
KUBE_VERSION=$(kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' || echo "Not installed")
echo "  Client: $KUBE_VERSION"
KUBE_SERVER=$(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' || echo "Cannot connect")
echo "  Server: $KUBE_SERVER"

# Talos
echo ""
echo "### Talos"
TALOS_CLIENT=$(talosctl version --client 2>/dev/null | grep "Tag:" | awk '{print $2}' || echo "Not installed")
echo "  Client: $TALOS_CLIENT"
TALOS_SERVER=$(talosctl --nodes 192.168.100.51 version 2>/dev/null | grep "Tag:" | head -1 | awk '{print $2}' || echo "Cannot connect")
echo "  Server: $TALOS_SERVER"

# Terraform
echo ""
echo "### Terraform"
TF_VERSION=$(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo "Not installed")
echo "  Version: $TF_VERSION"

# Cilium
echo ""
echo "### Cilium"
CILIUM_VERSION=$(kubectl get pods -n kube-system -l k8s-app=cilium -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null | cut -d':' -f2 || echo "Not deployed")
echo "  Version: $CILIUM_VERSION"

# MetalLB
echo ""
echo "### MetalLB"
METALLB_VERSION=$(kubectl get pods -n metallb-system -l app=metallb -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null | cut -d':' -f2 || echo "Not deployed")
echo "  Version: $METALLB_VERSION"

# Argo CD
echo ""
echo "### Argo CD"
ARGOCD_VERSION=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].spec.containers[0].image}' 2>/dev/null | cut -d':' -f2 || echo "Not deployed")
echo "  Version: $ARGOCD_VERSION"

echo ""
echo "=========================================="
echo "Version check complete"
echo "=========================================="
