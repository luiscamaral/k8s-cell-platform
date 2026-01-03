#!/bin/bash
# Memory Sync Script
# Updates memory files from current cluster state

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_DIR="$(dirname "$SCRIPT_DIR")"
MEMORY_DIR="$META_DIR/memory"

echo "=========================================="
echo "Syncing Memory Files"
echo "=========================================="

# Update current-state.md
echo "Updating current-state.md..."

# Get first control plane node IP for talosctl
FIRST_CP_IP=$(kubectl get nodes -l node-role.kubernetes.io/control-plane -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || echo "")

cat > "$MEMORY_DIR/current-state.md" << 'HEADER'
# Current Infrastructure State

HEADER

echo "Last updated: $(date +%Y-%m-%d)" >> "$MEMORY_DIR/current-state.md"

cat >> "$MEMORY_DIR/current-state.md" << 'SECTION1'

## Cluster Information

SECTION1

# Get cluster info
echo "- **Provider**: Proxmox" >> "$MEMORY_DIR/current-state.md"

KUBE_VERSION=$(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' 2>/dev/null || echo "Unknown")
echo "- **Kubernetes Version**: $KUBE_VERSION" >> "$MEMORY_DIR/current-state.md"

if [ -n "$FIRST_CP_IP" ]; then
    # Get server tag (skip client tag)
    TALOS_VERSION=$(talosctl --nodes "$FIRST_CP_IP" version 2>/dev/null | grep "Tag:" | tail -1 | awk '{print $2}' | tr -d '\n' || echo "Unknown")
    # Fallback: try getting from node OS image
    if [ -z "$TALOS_VERSION" ] || [ "$TALOS_VERSION" = "Unknown" ]; then
        TALOS_VERSION=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.osImage}' 2>/dev/null | sed 's/Talos (\(.*\))/\1/' || echo "Unknown")
    fi
else
    TALOS_VERSION="Unknown"
fi
echo "- **Talos Version**: $TALOS_VERSION" >> "$MEMORY_DIR/current-state.md"
echo "- **CNI**: Cilium (kube-proxy replacement)" >> "$MEMORY_DIR/current-state.md"

cat >> "$MEMORY_DIR/current-state.md" << 'SECTION2'

## Nodes

### Control Plane
| Node | IP | Status |
|------|-----|--------|
SECTION2

# Get control plane nodes
kubectl get nodes -l node-role.kubernetes.io/control-plane -o custom-columns='NAME:.metadata.name,IP:.status.addresses[?(@.type=="InternalIP")].address,STATUS:.status.conditions[?(@.type=="Ready")].status' --no-headers 2>/dev/null | while read -r name ip status; do
    if [ "$status" = "True" ]; then
        status="Ready"
    else
        status="NotReady"
    fi
    echo "| $name | $ip | $status |" >> "$MEMORY_DIR/current-state.md"
done

cat >> "$MEMORY_DIR/current-state.md" << 'SECTION3'

### Workers
| Node | IP | Status | Type |
|------|-----|--------|------|
SECTION3

# Get worker nodes
kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o custom-columns='NAME:.metadata.name,IP:.status.addresses[?(@.type=="InternalIP")].address,STATUS:.status.conditions[?(@.type=="Ready")].status' --no-headers 2>/dev/null | while read -r name ip status; do
    if [ "$status" = "True" ]; then
        status="Ready"
    else
        status="NotReady"
    fi
    type="Static"
    echo "| $name | $ip | $status | $type |" >> "$MEMORY_DIR/current-state.md"
done

cat >> "$MEMORY_DIR/current-state.md" << 'SECTION4'

## Layer Status

### L0 - Infrastructure
- **Status**: ✅ Deployed
- **Version**: 1.0.0

### L1 - Cluster Platform
SECTION4

METALLB_PODS=$(kubectl get pods -n metallb-system --no-headers 2>/dev/null | wc -l | tr -d ' ')
DNS_PODS=$(kubectl get pods -n external-dns --no-headers 2>/dev/null | wc -l | tr -d ' ')

if [ "$METALLB_PODS" -gt 0 ] && [ "$DNS_PODS" -gt 0 ]; then
    echo "- **Status**: ✅ Deployed" >> "$MEMORY_DIR/current-state.md"
else
    echo "- **Status**: ⚠️ Partial" >> "$MEMORY_DIR/current-state.md"
fi

cat >> "$MEMORY_DIR/current-state.md" << 'SECTION5'

### L2 - Core Platform
SECTION5

ARGOCD_PODS=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -c Running || echo 0)
KYVERNO_PODS=$(kubectl get pods -n kyverno --no-headers 2>/dev/null | grep -c Running || echo 0)

if [ "$ARGOCD_PODS" -gt 0 ] && [ "$KYVERNO_PODS" -gt 0 ]; then
    echo "- **Status**: ✅ Deployed" >> "$MEMORY_DIR/current-state.md"
elif [ "$ARGOCD_PODS" -gt 0 ] || [ "$KYVERNO_PODS" -gt 0 ]; then
    echo "- **Status**: 🔄 In Progress" >> "$MEMORY_DIR/current-state.md"
else
    echo "- **Status**: 📋 Planned" >> "$MEMORY_DIR/current-state.md"
fi

cat >> "$MEMORY_DIR/current-state.md" << 'SECTION6'

### L3-L7
- **Status**: 📋 Planned
- Not yet started

## Active Issues

None currently.

## Access Information

SECTION6

echo '```bash' >> "$MEMORY_DIR/current-state.md"
echo '# Kubernetes' >> "$MEMORY_DIR/current-state.md"
echo 'export KUBECONFIG=~/.kube/config' >> "$MEMORY_DIR/current-state.md"
echo 'kubectl get nodes' >> "$MEMORY_DIR/current-state.md"
echo '' >> "$MEMORY_DIR/current-state.md"
echo '# Talos' >> "$MEMORY_DIR/current-state.md"
echo 'export TALOSCONFIG=~/.talos/config' >> "$MEMORY_DIR/current-state.md"
if [ -n "$FIRST_CP_IP" ]; then
    echo "talosctl --nodes $FIRST_CP_IP health" >> "$MEMORY_DIR/current-state.md"
else
    echo 'talosctl --nodes <control-plane-ip> health' >> "$MEMORY_DIR/current-state.md"
fi
echo '```' >> "$MEMORY_DIR/current-state.md"

echo "Memory sync complete: $MEMORY_DIR/current-state.md"
