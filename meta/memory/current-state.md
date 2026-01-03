# Current Infrastructure State

Last updated: 2026-01-02

## Cluster Information

- **Provider**: Proxmox
- **Kubernetes Version**: v1.34.0
- **Talos Version**: v1.11.5
- **CNI**: Cilium (kube-proxy replacement)
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
- **Status**: ✅ Deployed (partial)
- **Version**: 1.3.0
- **Deployed**: MetalLB, nginx-ingress, metrics-server, external-dns, Linkerd, Karpenter
- **Config Ready**: cert-manager, NFS provisioner, MinIO (deploy with `make deploy-*`)

### L2 - Core Platform
- **Status**: ✅ Deployed
- **Version**: 0.3.0

### L3 - CI/Supply Chain
- **Status**: 🔧 Scaffolded
- **Version**: 0.1.0
- **Components**: ARC, Harbor, Trivy, Cosign (configuration ready)
- **Prerequisite**: Deploy L1 storage components first

### L4-L7
- **Status**: 📋 Planned
- Not yet started

## Pending Deployments

| Component | Layer | Command | Status |
|-----------|-------|---------|--------|
| cert-manager | L1 | `make deploy-cert-manager` | Config ready |
| NFS provisioner | L1 | `make deploy-storage` | Config ready |
| MinIO | L1 | `make deploy-minio` | Config ready |
| Harbor | L3 | `make deploy-harbor` | Waiting for L1 |
| ARC | L3 | `make deploy-arc` | Waiting for GitHub App |

## Active Issues

- external-dns: Intermittent CrashLoopBackOff (EndpointSlice timeout)

## Cell Configuration

Key settings from `meta/cell-config.yaml`:

| Setting | Value |
|---------|-------|
| Domain | lab.home |
| TLS Issuer | internal-ca |
| StorageClass | nfs-client |
| NFS Server | 192.168.100.254 |
| MinIO Endpoint | minio.lab.home |

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
