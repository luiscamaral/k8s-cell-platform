# Getting Started

Quick start guide for the Kubernetes Cell Platform.

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| terraform | >= 1.12 | Infrastructure provisioning |
| talosctl | >= 1.11 | Talos cluster management |
| kubectl | >= 1.30 | Kubernetes CLI |
| make | any | Automation |

### Optional Tools

| Tool | Purpose |
|------|---------|
| argocd | Argo CD CLI |
| linkerd | Linkerd CLI |
| helm | Helm charts |

## Infrastructure Requirements

### Proxmox (Homelab)

- Proxmox VE 8.0+
- At least 6 VMs available:
  - 3 control plane: 2 CPU, 4GB RAM each
  - 3 workers: 4 CPU, 8GB RAM each
- Network: 192.168.100.0/24

### Cloud (Future)

Cloud providers (AWS, Azure, GCP) are planned but not yet implemented.

## Deployment Steps

### 1. Clone Repository

```bash
git clone <repo-url>
cd kubernetes_cell_platform
```

### 2. Configure Environment

```bash
# L0: Terraform variables
cd l0_infrastructure/terraform/providers/proxmox
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Edit with your values
```

### 3. Deploy L0 (Infrastructure)

```bash
cd l0_infrastructure/terraform/providers/proxmox
terraform init
terraform plan
terraform apply
```

Wait for cluster to be ready (~5-10 minutes).

### 4. Verify L0

```bash
# Check nodes
kubectl get nodes

# Check Cilium
kubectl get pods -n kube-system -l k8s-app=cilium

# Check Talos
talosctl --nodes 192.168.100.51 health
```

### 5. Deploy L1 (Cluster Services)

```bash
cd l1_cluster-platform
make deploy-all
# Or individually:
kubectl apply -k metallb/
kubectl apply -k external-dns/
kubectl apply -k karpenter/
```

### 6. Verify L1

```bash
# Check components
kubectl get pods -n metallb-system
kubectl get pods -n external-dns
kubectl get pods -n karpenter

# Test LoadBalancer
kubectl apply -f test-service/
kubectl get svc whoami  # Should have external IP
```

### 7. Deploy L2 (Core Platform)

```bash
cd l2_core-platform
# Follow L2_IMPLEMENTATION_PLAN.md for phased deployment
```

## Verification

### Quick Health Check

```bash
cd meta
make status
```

### Integration Tests

```bash
cd meta
make test-integration
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Nodes not Ready | Check Cilium pods in kube-system |
| LoadBalancer Pending | Check MetalLB speaker pods |
| DNS not working | Check external-dns logs |

### Detailed Troubleshooting

Use the troubleshooting skill:
```
"Why is my pod crashing?" → troubleshooting-pods skill
```

Or check memory files:
- `meta/memory/troubleshooting-history.md`

## Next Steps

1. Complete L2 deployment (Argo CD, Kyverno, Linkerd)
2. Configure GitOps repositories
3. Deploy applications via Argo CD
