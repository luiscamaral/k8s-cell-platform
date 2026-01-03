# Component Ownership

Defines which layer owns each component and their responsibilities.

## Layer Ownership Matrix

| Component | Owner Layer | Namespace | Responsibility |
|-----------|-------------|-----------|----------------|
| Talos Linux | L0 | N/A (OS) | Node lifecycle, OS updates |
| Terraform | L0 | N/A | Infrastructure provisioning |
| Cilium | L0 | kube-system | CNI, network policies (Helm-managed) |
| CoreDNS | L0 | kube-system | Cluster DNS |
| etcd | L0 | N/A (Talos) | Cluster state |
| MetalLB | L1 | metallb-system | LoadBalancer services |
| nginx-ingress | L1 | ingress-nginx | Ingress controller |
| metrics-server | L1 | kube-system | Metrics API for HPA/VPA |
| external-dns | L1 | external-dns | DNS record automation |
| Linkerd | L1 | linkerd | Service mesh, mTLS (CLI-managed) |
| Linkerd-viz | L1 | linkerd-viz | Mesh observability (CLI-managed) |
| Karpenter | L1 | kube-system | Node autoscaling |
| Argo CD | L2 | argocd | GitOps deployment |
| Kyverno | L2 | kyverno | Policy enforcement |
| SOPS/age | L2 | N/A | Secret encryption |

## Boundary Rules

### L0 Owns
- **All node-level components**
- **CNI** (Cilium) - deployed via Helm
- **kube-proxy replacement** - handled by Cilium
- **Node OS updates** - via Talos upgrade

### L1 Owns
- **Cluster-level services** that L2+ components consume
- **LoadBalancer** - MetalLB provides external IPs
- **Ingress** - nginx-ingress controller for HTTP routing
- **Metrics API** - metrics-server for HPA/VPA/kubectl top
- **DNS automation** - external-dns manages records
- **Service mesh** - Linkerd provides mTLS (CLI-managed)
- **Node scaling** - Karpenter provisions/deprovisions

> **Management**: L1 components are deployed via Helm/Makefile, NOT ArgoCD.
> Run `make deploy-all` in `l1_cluster-platform/` directory.
> Linkerd is managed via `linkerd` CLI, not Helm.

### L2 Owns
- **Application deployment** - Argo CD manages workloads
- **Policy enforcement** - Kyverno validates resources

## Cross-Layer Dependencies

```
L0: Talos + Cilium (provides cluster, CNI)
    ↓
L1: MetalLB + nginx-ingress + metrics-server + external-dns + Linkerd + Karpenter
    ↓
L2: Argo CD + Kyverno (provides GitOps and policy)
    ↓
L3+: Applications (consume platform)
```

## Upgrade Responsibility

| Upgrade Type | Responsible Layer | Impact |
|--------------|-------------------|--------|
| Kubernetes version | L0 | Cluster-wide |
| Talos version | L0 | Node OS |
| Cilium version | L0 | Networking |
| MetalLB version | L1 | LoadBalancer |
| Argo CD version | L2 | GitOps |
| Application images | L2+ | App-specific |

## Troubleshooting Ownership

| Symptom | First Check | Owner |
|---------|-------------|-------|
| Node not Ready | L0 | Talos, Cilium |
| Pod networking | L0 | Cilium |
| LoadBalancer Pending | L1 | MetalLB |
| Ingress not routing | L1 | nginx-ingress |
| kubectl top not working | L1 | metrics-server |
| DNS not resolving | L1 | external-dns |
| mTLS issues | L1 | Linkerd |
| App not syncing | L2 | Argo CD |
| Policy blocking | L2 | Kyverno |
