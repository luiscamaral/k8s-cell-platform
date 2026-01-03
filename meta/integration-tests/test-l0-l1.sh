#!/bin/bash
# L0→L1 Integration Test
# Validates that L0 provides what L1 requires

set -euo pipefail

echo "=========================================="
echo "L0→L1 Integration Test"
echo "=========================================="

PASSED=0
FAILED=0

test_case() {
    local name="$1"
    local cmd="$2"
    local expected="$3"

    echo -n "Testing: $name... "
    if eval "$cmd" &>/dev/null; then
        echo "✅ PASS"
        ((PASSED++))
    else
        echo "❌ FAIL (expected: $expected)"
        ((FAILED++))
    fi
}

echo ""
echo "## L0 Provides (Prerequisites for L1)"
echo ""

# Cluster access
test_case "Kubernetes API accessible" \
    "kubectl get nodes" \
    "Cluster reachable"

# Nodes ready
test_case "All nodes Ready" \
    "kubectl get nodes --no-headers | grep -v Ready | wc -l | grep -q '^0$'" \
    "No NotReady nodes"

# Cilium running
test_case "Cilium CNI running" \
    "kubectl get pods -n kube-system -l k8s-app=cilium --no-headers | grep -v Running | wc -l | grep -q '^0$'" \
    "All Cilium pods Running"

# Network connectivity
test_case "Pod network functional" \
    "kubectl run test-ping --image=busybox --rm -it --restart=Never --command -- ping -c 1 10.96.0.1" \
    "Can reach service network"

echo ""
echo "## L1 Status"
echo ""

# MetalLB
test_case "MetalLB deployed" \
    "kubectl get namespace metallb-system" \
    "Namespace exists"

test_case "MetalLB pods running" \
    "kubectl get pods -n metallb-system --no-headers | grep -v Running | wc -l | grep -q '^0$'" \
    "All pods Running"

test_case "IP pool configured" \
    "kubectl get ipaddresspools -n metallb-system --no-headers | wc -l | grep -qv '^0$'" \
    "At least one IP pool"

# external-dns
test_case "external-dns deployed" \
    "kubectl get namespace external-dns" \
    "Namespace exists"

test_case "external-dns running" \
    "kubectl get pods -n external-dns --no-headers | grep -v Running | wc -l | grep -q '^0$'" \
    "All pods Running"

# Karpenter
test_case "Karpenter deployed" \
    "kubectl get namespace karpenter" \
    "Namespace exists"

# LoadBalancer integration
test_case "LoadBalancer assigns IPs" \
    "kubectl get svc -A -o jsonpath='{.items[?(@.spec.type==\"LoadBalancer\")].status.loadBalancer.ingress}' | grep -q '192.168'" \
    "IPs in expected range"

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
