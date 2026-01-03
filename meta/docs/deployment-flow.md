# Deployment Flow

Step-by-step deployment flow for the Kubernetes Cell Platform.

## Overview

```
Phase 0: Prerequisites
    ↓
Phase 1: L0 Infrastructure (5-10 min)
    ↓
Phase 2: L1 Cluster Platform (2-5 min)
    ↓
Phase 3: L2 Core Platform (5-10 min)
    ↓
Phase 4: Applications (ongoing)
```

## Phase 0: Prerequisites

### Verify Tools

```bash
# Required
terraform version    # >= 1.12
talosctl version     # >= 1.11
kubectl version      # >= 1.30

# Optional
argocd version
linkerd version
```

### Configure Proxmox

1. Create resource pool for cluster
2. Upload Talos ISO
3. Configure network (VLAN if needed)
4. Prepare storage for VMs

### Prepare Configuration

```bash
cd l0_infrastructure/terraform/providers/proxmox
cp terraform.tfvars.example terraform.tfvars
# Edit with your environment values
```

## Phase 1: L0 Infrastructure

### Step 1.1: Initialize Terraform

```bash
cd l0_infrastructure/terraform/providers/proxmox
terraform init
```

### Step 1.2: Review Plan

```bash
terraform plan -out=tfplan
# Review the plan carefully
```

### Step 1.3: Apply Infrastructure

```bash
terraform apply tfplan
# Wait for completion (~5-10 minutes)
```

### Step 1.4: Configure Access

```bash
# Terraform outputs kubeconfig and talosconfig
# They should be automatically configured

# Verify Kubernetes access
kubectl get nodes

# Verify Talos access
talosctl --nodes 192.168.100.51 health
```

### Step 1.5: Verify L0

```bash
# All nodes should be Ready
kubectl get nodes -o wide

# Cilium should be running
kubectl get pods -n kube-system -l k8s-app=cilium

# etcd should be healthy
talosctl --nodes 192.168.100.51 etcd status
```

## Phase 2: L1 Cluster Platform

### Step 2.1: Deploy MetalLB

```bash
cd l1_cluster-platform
kubectl apply -k metallb/

# Verify
kubectl get pods -n metallb-system
kubectl get ipaddresspools -n metallb-system
```

### Step 2.2: Deploy external-dns

```bash
kubectl apply -k external-dns/

# Verify
kubectl get pods -n external-dns
kubectl logs -n external-dns -l app.kubernetes.io/name=external-dns
```

### Step 2.3: Deploy Karpenter

```bash
kubectl apply -k karpenter/

# Verify
kubectl get pods -n karpenter
kubectl get nodepools
```

### Step 2.4: Test Integration

```bash
# Deploy test service
kubectl apply -f test-service/

# Verify LoadBalancer IP
kubectl get svc whoami
# Should have EXTERNAL-IP

# Verify DNS (if external-dns configured)
nslookup whoami.homelab.local
```

### Step 2.5: Verify L1

```bash
# Run L1 validation
./scripts/test-loadbalancer.sh

# Or use meta Makefile
cd ../meta
make test-l0-l1
```

## Phase 3: L2 Core Platform

### Step 3.1: Deploy Argo CD

```bash
cd l2_core-platform

# Create namespace
kubectl create namespace argocd

# Deploy Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Step 3.2: Access Argo CD UI

```bash
# Port forward (temporary)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Or expose via LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl get svc argocd-server -n argocd
```

### Step 3.3: Configure Repositories

```bash
# Login to Argo CD
argocd login localhost:8080

# Add repository
argocd repo add https://github.com/<org>/<repo> --username <user> --password <token>
```

### Step 3.4: Deploy App-of-Apps

```bash
# Apply root application
kubectl apply -f argocd/app-of-apps.yaml

# Monitor sync
argocd app get app-of-apps
```

### Step 3.5: Deploy Kyverno (via Argo CD)

Kyverno should be deployed automatically via App-of-Apps pattern.

```bash
# Verify
kubectl get pods -n kyverno
kubectl get clusterpolicies
```

### Step 3.6: Deploy Linkerd (via Argo CD)

```bash
# Verify
linkerd check
kubectl get pods -n linkerd
```

## Phase 4: Applications

### GitOps Workflow

1. Create application manifests in Git
2. Create Argo CD Application resource
3. Argo CD syncs automatically
4. Kyverno validates resources
5. Linkerd injects sidecars (if annotated)

### Example Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/repo
    targetRevision: HEAD
    path: manifests/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Rollback Procedures

### L0 Rollback

```bash
# Terraform destroy (DESTRUCTIVE)
cd l0_infrastructure/terraform/providers/proxmox
terraform destroy

# Or specific resource
terraform destroy -target=module.talos_cluster
```

### L1 Rollback

```bash
# Delete components
kubectl delete -k l1_cluster-platform/metallb/
kubectl delete -k l1_cluster-platform/external-dns/
kubectl delete -k l1_cluster-platform/karpenter/
```

### L2 Rollback

```bash
# Delete via Argo CD
argocd app delete app-of-apps --cascade

# Or manual
kubectl delete namespace argocd kyverno linkerd
```
