# Architecture Overview

Comprehensive architecture documentation for the Kubernetes Cell Platform.

## Design Philosophy

### Core Principles

1. **Vendor Neutral** - 100% open-source, no cloud lock-in
2. **GitOps First** - Git is the single source of truth
3. **Immutable Infrastructure** - Talos Linux, no SSH access
4. **Security by Default** - mTLS, RBAC, network policies
5. **Layered Architecture** - Clear separation of concerns

### Layer Model

```
┌─────────────────────────────────────────────────────────┐
│ L7: Developer Portal (Backstage)                        │
├─────────────────────────────────────────────────────────┤
│ L6: Security (Falco, RBAC, Network Policies)            │
├─────────────────────────────────────────────────────────┤
│ L5: Resilience (Velero, Chaos Engineering)              │
├─────────────────────────────────────────────────────────┤
│ L4: Observability (Prometheus, Loki, Tempo, Grafana)    │
├─────────────────────────────────────────────────────────┤
│ L3: CI/Supply Chain (Tekton, Harbor, Gitea)             │
├─────────────────────────────────────────────────────────┤
│ L2: Core Platform (Argo CD, Kyverno, Linkerd)           │
├─────────────────────────────────────────────────────────┤
│ L1: Cluster Platform (MetalLB, external-dns, Karpenter) │
├─────────────────────────────────────────────────────────┤
│ L0: Infrastructure (Terraform, Talos Linux, Cilium)     │
└─────────────────────────────────────────────────────────┘
```

## Layer Details

### L0: Infrastructure

**Purpose**: Provision foundational compute, networking, and storage.

**Components**:
- Terraform - Infrastructure as Code
- Talos Linux - Immutable Kubernetes OS
- Cilium - eBPF-based CNI

**Responsibilities**:
- VM/node provisioning
- Kubernetes cluster lifecycle
- Network connectivity (CNI)
- OS updates

### L1: Cluster Platform

**Purpose**: Provide cluster-level capabilities for applications.

**Components**:
- MetalLB - LoadBalancer for bare-metal
- external-dns - DNS automation
- Karpenter - Node autoscaling

**Responsibilities**:
- External IP assignment
- DNS record management
- Dynamic node provisioning

### L2: Core Platform

**Purpose**: Application deployment governance and operations.

**Components**:
- Argo CD - GitOps control plane
- Kyverno - Policy enforcement
- Linkerd - Service mesh

**Responsibilities**:
- GitOps workflows
- Policy validation
- mTLS encryption
- Observability (via Linkerd)

### L3-L7: Application Layers (Planned)

Future layers for:
- CI/CD pipelines
- Observability stack
- Resilience tooling
- Security scanning
- Developer experience

## Network Architecture

```
┌─────────────────────────────────────────────────────────┐
│ External Network: 192.168.100.0/24                      │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ CP-1        │  │ CP-2        │  │ CP-3        │     │
│  │ .51         │  │ .52         │  │ .53         │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Worker-1    │  │ Worker-2    │  │ Worker-3    │     │
│  │ .61         │  │ .62         │  │ .63         │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
│  LoadBalancer Pool: .200-.250                           │
└─────────────────────────────────────────────────────────┘

Internal Networks:
- Pod CIDR: 10.244.0.0/16
- Service CIDR: 10.96.0.0/16
- Control Plane Endpoint: 192.168.100.50:6443
```

## Security Model

### Defense in Depth

```
Layer 1: Network (Cilium network policies)
    ↓
Layer 2: Admission (Kyverno policies)
    ↓
Layer 3: Runtime (Falco monitoring) [planned]
    ↓
Layer 4: Encryption (Linkerd mTLS)
    ↓
Layer 5: Secrets (SOPS + age encryption)
```

### Key Security Features

- **Immutable OS**: Talos Linux has no SSH, no shell
- **Network Policies**: Cilium eBPF-based enforcement
- **Policy Admission**: Kyverno validates all resources
- **mTLS**: Linkerd encrypts all service traffic
- **Secrets Encryption**: SOPS + age for GitOps

## Data Flow

### Deployment Flow

```
1. Developer pushes to Git
   ↓
2. Argo CD detects change
   ↓
3. Kyverno validates resources
   ↓
4. Resources applied to cluster
   ↓
5. Linkerd injects sidecar (if meshed)
   ↓
6. MetalLB assigns external IP
   ↓
7. external-dns creates DNS record
```

### Traffic Flow

```
External Request
    ↓
LoadBalancer (MetalLB)
    ↓
Ingress Controller [planned]
    ↓
Service (with Linkerd sidecar)
    ↓
Pod (application)
```

## Technology Choices

| Category | Choice | Rationale |
|----------|--------|-----------|
| OS | Talos Linux | Immutable, API-driven |
| CNI | Cilium | eBPF, kube-proxy replacement |
| LoadBalancer | MetalLB | Bare-metal support |
| GitOps | Argo CD | Mature, App-of-Apps |
| Policy | Kyverno | Kubernetes-native |
| Mesh | Linkerd | Lightweight, simple |
| Secrets | SOPS + age | Git-native encryption |

## Scalability

### Current Capacity

- 3 control plane nodes (HA)
- 3 static + 0-10 dynamic workers
- ~55 second scale-up time (Karpenter)

### Future Scaling

- Multi-cluster support (Argo CD)
- Federation capabilities
- Cloud provider expansion
