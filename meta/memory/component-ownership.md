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
| cert-manager | L1 | cert-manager | TLS certificate automation |
| NFS Provisioner | L1 | nfs-provisioner | PersistentVolume provisioning |
| MinIO | L1 | minio | S3-compatible object storage |
| Argo CD | L2 | argocd | GitOps deployment |
| Kyverno | L2 | kyverno | Policy enforcement |
| SOPS/age | L2 | N/A | Secret encryption |
| Actions Runner Controller | L3 | arc-systems | GitHub self-hosted runners |
| Harbor | L3 | harbor | Container registry |
| Trivy Operator | L3 | trivy-system | Vulnerability scanning |
| Cosign | L3 | N/A | Image signing (CLI tool) |

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
- **TLS certificates** - cert-manager with internal CA
- **Persistent storage** - NFS provisioner for PVCs
- **Object storage** - MinIO S3-compatible storage

> **Management**: L1 components are deployed via Helm/Makefile, NOT ArgoCD.
> Run `make deploy-all` in `l1_cluster-platform/` directory.
> Linkerd is managed via `linkerd` CLI, not Helm.

### L2 Owns
- **Application deployment** - Argo CD manages workloads
- **Policy enforcement** - Kyverno validates resources
- **Image verification** - Kyverno + Cosign policies

### L3 Owns
- **CI/CD runners** - Actions Runner Controller for GitHub
- **Container registry** - Harbor for image storage
- **Vulnerability scanning** - Trivy Operator
- **Image signing** - Cosign integration

> **Management**: L3 components deployed via Helm/Makefile.
> L3 requires L1 storage components (cert-manager, NFS, MinIO).

## Cross-Layer Dependencies

```
L0: Talos + Cilium (provides cluster, CNI)
    ↓
L1: MetalLB + nginx-ingress + external-dns + Linkerd + Karpenter
    + cert-manager + NFS provisioner + MinIO
    ↓
L2: Argo CD + Kyverno (provides GitOps and policy)
    ↓
L3: ARC + Harbor + Trivy + Cosign (CI/CD and supply chain)
    ↓
L4+: Observability, Resilience, Security, Developer Portal
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
| Certificate not issued | L1 | cert-manager |
| PVC Pending | L1 | NFS provisioner |
| S3 access denied | L1 | MinIO |
| App not syncing | L2 | Argo CD |
| Policy blocking | L2 | Kyverno |
| Runner not picking jobs | L3 | ARC |
| Image push failed | L3 | Harbor |
| Vulnerability scan missing | L3 | Trivy |
| Signature verification failed | L3 | Cosign/Kyverno |
