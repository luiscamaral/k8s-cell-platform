# Current Infrastructure State

Last updated: 2026-01-03

## Cluster Information

- **Provider**: Proxmox
- **Kubernetes Version**: v1.34.0
- **Talos Version**: v1.12.0
- **CNI**: Cilium (kube-proxy replacement)
- **VM Storage**: thin-pool-ssd (Proxmox)
- **Cell Config**: `meta/cell-config.yaml`

## Nodes

### Control Plane
| Node | IP | Status |
|------|-----|--------|
| talos-50r-r98 | 192.168.100.88 | Ready |
| talos-5l2-6vv | 192.168.100.143 | Ready |
| talos-k2s-srl | 192.168.100.199 | Ready |

### Workers
| Node | IP | Status | Type |
|------|-----|--------|------|
| talos-0ga-y7a | 192.168.100.76 | Ready | Static |
| talos-1fg-ltu | 192.168.100.32 | Ready | Static |
| talos-39z-dot | 192.168.100.50 | Ready | Static |

## Layer Status

### L0 - Infrastructure
- **Status**: ✅ Deployed
- **Version**: 1.0.0

### L1 - Cluster Platform
- **Status**: ✅ Deployed
- **Version**: 1.3.0
- **Deployed**: MetalLB, nginx-ingress, metrics-server, external-dns, Linkerd, Karpenter, cert-manager, NFS provisioner, MinIO

### L2 - Core Platform
- **Status**: ✅ Deployed
- **Version**: 0.3.0

### L3 - CI/Supply Chain
- **Status**: 🚀 Partial
- **Version**: 0.2.0
- **Deployed**: Harbor (container registry)
- **Pending**: ARC (needs GitHub App), Trivy Operator

### L4-L7
- **Status**: 📋 Planned
- Not yet started

## Pending Deployments

| Component | Layer | Command | Status |
|-----------|-------|---------|--------|
| ARC | L3 | `make deploy-arc` | Waiting for GitHub App |
| Trivy Operator | L3 | `make deploy-trivy` | Ready to deploy |
| Kubernetes upgrade | L0 | `talosctl upgrade-k8s --to 1.35.0` | Deferred (retry when ready) |
| MinIO upgrade | L1 | `make deploy-minio` | 5.3.0 → 5.4.0 (Makefile updated) |

## Resolved Issues

- external-dns: Fixed RBAC (added endpointslices permission)
- Talos upgrade: v1.11.5 → v1.12.0 completed on all 6 nodes
- Storage: Migrated all k8s VM disks from `local-lvm` to `thin-pool-ssd` (local-lvm was 100% full causing I/O errors)
- Harbor deployed: Container registry at https://harbor.lab.home with MinIO S3 backend

## Cell Configuration

Key settings from `meta/cell-config.yaml`:

| Setting | Value |
|---------|-------|
| Domain | lab.home |
| TLS Issuer | internal-ca |
| StorageClass | nfs-client |
| NFS Server | 192.168.2.50 |
| NFS Path | /volume2/shared/servers/k8s-storage |
| MinIO API | https://minio.lab.home |
| MinIO Console | https://minio-console.lab.home |
| Harbor | https://harbor.lab.home |

## Access Information

```bash
# Kubernetes
export KUBECONFIG=~/.kube/config
kubectl get nodes

# Talos
export TALOSCONFIG=~/.talos/config
talosctl --nodes 192.168.100.88 health

# L1 Status
cd l1_cluster-platform && make status
```
