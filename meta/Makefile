# Meta Layer Makefile
# Cross-layer orchestration commands

.PHONY: help status check-versions test-integration sync-memory deploy-all

help:
	@echo "Kubernetes Cell Platform - Meta Commands"
	@echo ""
	@echo "Status:"
	@echo "  make status          - Show platform status"
	@echo "  make check-versions  - Validate version compatibility"
	@echo ""
	@echo "Testing:"
	@echo "  make test-integration - Run cross-layer integration tests"
	@echo "  make test-l0-l1      - Test L0→L1 integration"
	@echo "  make test-l1-l2      - Test L1→L2 integration"
	@echo ""
	@echo "Memory:"
	@echo "  make sync-memory     - Update memory files from cluster"
	@echo ""
	@echo "Deploy:"
	@echo "  make deploy-l0       - Deploy L0 infrastructure"
	@echo "  make deploy-l1       - Deploy L1 cluster services"
	@echo "  make deploy-l2       - Deploy L2 core platform"
	@echo "  make deploy-all      - Deploy all layers"

status:
	@echo "=== Kubernetes Cell Platform Status ==="
	@echo ""
	@echo "Cluster:"
	@kubectl get nodes -o wide 2>/dev/null || echo "Cannot connect to cluster"
	@echo ""
	@echo "Layers:"
	@echo "  L0 (Infrastructure): $$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ') nodes"
	@echo "  L1 (Cluster Services):"
	@echo "    - MetalLB: $$(kubectl get pods -n metallb-system --no-headers 2>/dev/null | wc -l | tr -d ' ') pods"
	@echo "    - External-DNS: $$(kubectl get pods -n external-dns --no-headers 2>/dev/null | wc -l | tr -d ' ') pods"
	@echo "    - Karpenter: $$(kubectl get pods -n karpenter --no-headers 2>/dev/null | wc -l | tr -d ' ') pods"
	@echo "  L2 (Core Platform):"
	@echo "    - Argo CD: $$(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l | tr -d ' ') pods"
	@echo "    - Kyverno: $$(kubectl get pods -n kyverno --no-headers 2>/dev/null | wc -l | tr -d ' ') pods"
	@echo "    - Linkerd: $$(kubectl get pods -n linkerd --no-headers 2>/dev/null | wc -l | tr -d ' ') pods"

check-versions:
	@./scripts/check-versions.sh

test-integration: test-l0-l1 test-l1-l2

test-l0-l1:
	@./integration-tests/test-l0-l1.sh

test-l1-l2:
	@./integration-tests/test-l1-l2.sh

sync-memory:
	@./scripts/sync-memory.sh

deploy-l0:
	@echo "Deploying L0..."
	@cd ../l0_infrastructure/terraform/providers/proxmox && terraform apply

deploy-l1:
	@echo "Deploying L1..."
	@cd ../l1_cluster-platform && make deploy-all

deploy-l2:
	@echo "Deploying L2..."
	@cd ../l2_core-platform && ./scripts/deploy-phase1.sh

deploy-all: deploy-l0 deploy-l1 deploy-l2
	@echo "All layers deployed"
