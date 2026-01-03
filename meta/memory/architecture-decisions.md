# Architecture Decisions

Summary of key architectural decisions for the Kubernetes Cell Platform.

## ADR-001: Use Talos Linux

**Status**: Accepted
**Date**: 2024-11-01
**Location**: `l0_infrastructure/docs/adr/001-use-talos-linux.md`

### Decision
Use Talos Linux as the Kubernetes OS for all nodes.

### Rationale
- Immutable OS eliminates configuration drift
- API-driven management (no SSH required)
- Purpose-built for Kubernetes
- Minimal attack surface
- Provider-agnostic (AWS, Azure, GCP, vSphere, Proxmox)

### Alternatives Considered
- Flatcar Container Linux
- Ubuntu Server
- Bottlerocket
- k3OS

---

## ADR-002: Cilium via Talos Inline Manifests

**Status**: Accepted
**Date**: 2024-11-15

### Decision
Deploy Cilium CNI via Talos inline manifests rather than post-bootstrap.

### Rationale
- No chicken-and-egg problem with CNI
- CNI available immediately at bootstrap
- Consistent across all nodes
- No race conditions with pod scheduling

### Implementation
Cilium manifests embedded in Talos machine configuration.

---

## ADR-003: Layer Separation

**Status**: Accepted
**Date**: 2024-11-01

### Decision
Organize platform into 7 distinct layers with clear boundaries.

### Rationale
- Clear separation of concerns
- Independent lifecycle management
- Easier troubleshooting
- Team ownership boundaries

### Layers
1. L0: Infrastructure (Terraform, Talos)
2. L1: Cluster Platform (MetalLB, DNS, Karpenter)
3. L2: Core Platform (GitOps, Policy, Mesh)
4. L3: CI/Supply Chain
5. L4: Observability
6. L5: Resilience
7. L7: Developer Portal

---

## ADR-004: GitOps with Argo CD

**Status**: Accepted
**Date**: 2024-12-01

### Decision
Use Argo CD for GitOps-based application deployment.

### Rationale
- Mature, widely adopted
- App-of-Apps pattern support
- UI for visibility
- Multi-cluster support for future

### Pattern
App-of-Apps with project-based organization.

---

## ADR-005: Kyverno for Policy

**Status**: Accepted
**Date**: 2024-12-01

### Decision
Use Kyverno instead of OPA/Gatekeeper for policy enforcement.

### Rationale
- Kubernetes-native (uses CRDs)
- No new language to learn (YAML-based)
- Mutation and validation in one tool
- Image verification support

---

## ADR-006: SOPS + age for Secrets

**Status**: Accepted
**Date**: 2024-12-01

### Decision
Use SOPS with age encryption for secrets in Git.

### Rationale
- Git-native secret management
- No external dependency (unlike Vault)
- Simple key management with age
- Works with Argo CD

### Alternative Considered
- Sealed Secrets
- HashiCorp Vault
- External Secrets Operator

---

## ADR-007: Proxmox as Primary Provider

**Status**: Accepted
**Date**: 2024-11-01

### Decision
Focus on Proxmox as the primary infrastructure provider.

### Rationale
- Homelab-friendly
- Cost-effective
- Full control over infrastructure
- Good Terraform provider support

### Future
Cloud providers (AWS, Azure, GCP) planned as secondary options.

---

## Pending Decisions

### Meta Repository
- Whether to create a separate meta repository for cross-layer orchestration
- Current approach: meta/ directory within main repo

### Multi-Cluster
- Strategy for managing multiple clusters
- Fleet management approach
