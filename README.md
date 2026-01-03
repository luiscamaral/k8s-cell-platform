# Kubernetes Cell Platform

A modular 7-layer architecture for deploying production-grade Kubernetes clusters on Proxmox VE.

## Architecture

```
Layer 7: Developer Portal     │ Backstage (planned)
Layer 6: Security             │ Falco (planned)
Layer 5: Resilience           │ Velero (planned)
Layer 4: Observability        │ Prometheus, Grafana (planned)
Layer 3: CI/Supply Chain      │ ARC, Harbor, Trivy, Cosign 🔧
Layer 2: Core Platform        │ ArgoCD, Kyverno ✅
Layer 1: Cluster Services     │ MetalLB, DNS, Linkerd, cert-manager, MinIO ✅
Layer 0: Infrastructure       │ Terraform, Talos, Cilium ✅
```

## Repository Structure

This is a monorepo using Git submodules:

```
k8s-cell-platform/
├── l0_infrastructure/     # Submodule: Terraform + Talos Linux
├── l1_cluster-platform/   # Submodule: Cluster services + storage + TLS
├── l2_core-platform/      # Submodule: GitOps + Policy (ArgoCD, Kyverno)
├── l3_ci-supply-chain/    # Submodule: CI/CD + Supply chain security
├── meta/                  # Cross-layer coordination (versions, contracts, cell config)
├── .claude-skills/        # Submodule: Claude Code skills
└── .claude/               # Symlinks to skills
    ├── skills -> ../.claude-skills/
    └── CLAUDE.md -> ../.claude-skills/CLAUDE.md
```

## Quick Start

### Clone with submodules

```bash
git clone --recurse-submodules https://github.com/luiscamaral/k8s-cell-platform.git
cd k8s-cell-platform
```

### Update all submodules

```bash
git pull --recurse-submodules
git submodule update --remote --merge
```

## Layer Details

| Layer | Repository | Description | Status |
|-------|------------|-------------|--------|
| L0 | [k8s-cell-platform-l0](https://github.com/luiscamaral/k8s-cell-platform-l0) | Terraform + Talos infrastructure | ✅ Deployed |
| L1 | [k8s-cell-platform-l1](https://github.com/luiscamaral/k8s-cell-platform-l1) | MetalLB, Linkerd, cert-manager, MinIO | ✅ Deployed |
| L2 | [k8s-cell-platform-l2](https://github.com/luiscamaral/k8s-cell-platform-l2) | ArgoCD, Kyverno | ✅ Deployed |
| L3 | [k8s-cell-platform-l3](https://github.com/luiscamaral/k8s-cell-platform-l3) | ARC, Harbor, Trivy, Cosign | 🔧 Scaffolded |
| Skills | [k8s-cell-platform-skills](https://github.com/luiscamaral/k8s-cell-platform-skills) | Claude Code skills | ✅ Ready |

## Current Versions

See `meta/versions.yaml` for the full compatibility matrix.

| Component | Version | Layer |
|-----------|---------|-------|
| Kubernetes | 1.34.0 | L0 |
| Talos Linux | 1.11.5 | L0 |
| Cilium | 1.18.5 | L0 |
| cert-manager | 1.16.2 | L1 |
| MinIO | 5.3.0 | L1 |
| ArgoCD | 3.2.3 | L2 |
| Kyverno | 1.16.1 | L2 |
| Harbor | 2.11.0 | L3 |

## Cell Configuration

Customize your deployment via `meta/cell-config.yaml`:

```yaml
domain:
  base: "lab.home"          # Internal domain
  public: "example.com"     # Public domain (for Let's Encrypt)

storage:
  class: "nfs-client"
  nfs:
    server: "192.168.100.254"
    path: "/volume1/k8s-storage"

s3:
  endpoint: "minio.lab.home"
  buckets:
    harbor: "harbor-registry"
    velero: "velero-backups"
```

## Development Workflow

### Make changes to a layer

```bash
cd l1_cluster-platform
# make changes
git commit -am "feat: update"
git push

cd ..
git add l1_cluster-platform
git commit -m "chore: update l1 submodule"
git push
```

### Update meta (cross-layer coordination)

```bash
# meta is in parent repo, no submodule update needed
git add meta/
git commit -m "chore: update meta"
git push
```

## License

Private project - All rights reserved.
