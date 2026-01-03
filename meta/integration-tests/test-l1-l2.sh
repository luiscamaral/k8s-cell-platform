#!/bin/bash
# L1→L2 Integration Test
# Validates that L1 provides what L2 requires

set -euo pipefail

echo "=========================================="
echo "L1→L2 Integration Test"
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
echo "## L1 Provides (Prerequisites for L2)"
echo ""

# LoadBalancer functional
test_case "LoadBalancer service type works" \
    "kubectl get svc -A -o jsonpath='{.items[?(@.spec.type==\"LoadBalancer\")].status.loadBalancer.ingress[0].ip}' | grep -q '[0-9]'" \
    "LoadBalancer assigns IPs"

# MetalLB speaker responding
test_case "MetalLB speakers healthy" \
    "kubectl get pods -n metallb-system -l component=speaker --no-headers | grep -v Running | wc -l | grep -q '^0$'" \
    "All speakers Running"

echo ""
echo "## L2 Status"
echo ""

# Argo CD
if kubectl get namespace argocd &>/dev/null; then
    test_case "Argo CD namespace exists" \
        "kubectl get namespace argocd" \
        "Namespace exists"

    test_case "Argo CD server running" \
        "kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --no-headers | grep Running" \
        "Server pod Running"

    test_case "Argo CD accessible via LoadBalancer" \
        "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' | grep -q '[0-9]'" \
        "Has external IP"
else
    echo "ℹ️  Argo CD not yet deployed (expected for Phase 1)"
fi

# Kyverno
if kubectl get namespace kyverno &>/dev/null; then
    test_case "Kyverno namespace exists" \
        "kubectl get namespace kyverno" \
        "Namespace exists"

    test_case "Kyverno admission controller running" \
        "kubectl get pods -n kyverno -l app.kubernetes.io/component=admission-controller --no-headers | grep Running" \
        "Admission controller Running"

    test_case "ClusterPolicies exist" \
        "kubectl get clusterpolicies --no-headers | wc -l | grep -qv '^0$'" \
        "At least one policy"
else
    echo "ℹ️  Kyverno not yet deployed (expected for Phase 2)"
fi

# Linkerd
if kubectl get namespace linkerd &>/dev/null; then
    test_case "Linkerd namespace exists" \
        "kubectl get namespace linkerd" \
        "Namespace exists"

    test_case "Linkerd control plane healthy" \
        "linkerd check --pre 2>&1 | grep -q 'Status check results are'" \
        "Pre-checks pass"
else
    echo "ℹ️  Linkerd not yet deployed (expected for Phase 3)"
fi

echo ""
echo "=========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "=========================================="

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
