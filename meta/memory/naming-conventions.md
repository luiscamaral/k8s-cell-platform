# Naming Conventions

Standard naming conventions for the Kubernetes Cell Platform.

## Directory Naming

| Type | Convention | Example |
|------|------------|---------|
| Layer directories | `lN_descriptive-name` | `l0_infrastructure`, `l1_cluster-platform` |
| Sub-directories | kebab-case | `external-dns`, `test-service` |
| Generated content | `generated/` | `generated/docs/` |
| Documentation | `docs/` | `docs/adr/` |

## File Naming

| Type | Convention | Example |
|------|------------|---------|
| Kubernetes manifests | kebab-case.yaml | `ip-address-pool.yaml` |
| Shell scripts | kebab-case.sh | `validate-cluster.sh` |
| Markdown docs | UPPER_SNAKE.md for top-level | `README.md`, `CLAUDE.md` |
| Markdown docs | kebab-case.md for regular | `getting-started.md` |
| Terraform files | snake_case.tf | `main.tf`, `variables.tf` |

## Kubernetes Resources

### Namespaces

| Pattern | Example | Use Case |
|---------|---------|----------|
| `<component>` | `metallb-system` | System components |
| `<app>-<env>` | `myapp-prod` | Application workloads |

### Deployments/Services

| Pattern | Example |
|---------|---------|
| Component name | `external-dns` |
| App + function | `frontend-api` |

### ConfigMaps/Secrets

| Pattern | Example |
|---------|---------|
| `<app>-config` | `argocd-config` |
| `<app>-secret` | `registry-secret` |

## Labels

### Standard Labels

```yaml
labels:
  app.kubernetes.io/name: <component>
  app.kubernetes.io/instance: <instance>
  app.kubernetes.io/version: <version>
  app.kubernetes.io/component: <component-type>
  app.kubernetes.io/part-of: <platform>
  app.kubernetes.io/managed-by: <tool>
```

### Platform Labels

```yaml
labels:
  platform.cell/layer: l1
  platform.cell/component: metallb
```

## Git Conventions

### Branch Names

| Pattern | Example | Use Case |
|---------|---------|----------|
| `feature/<description>` | `feature/add-karpenter` | New features |
| `fix/<description>` | `fix/metallb-speaker` | Bug fixes |
| `chore/<description>` | `chore/update-deps` | Maintenance |

### Commit Messages

```
<type>(<scope>): <description>

Types: feat, fix, docs, chore, refactor, test
Scope: l0, l1, l2, meta, skills
```

Examples:
- `feat(l1): add Karpenter for node autoscaling`
- `fix(l0): correct Cilium inline manifest`
- `docs(meta): update architecture decisions`

## Terraform Conventions

### Variable Names

```hcl
variable "cluster_name" {}      # snake_case
variable "control_plane_count" {}
```

### Resource Names

```hcl
resource "proxmox_vm" "control_plane" {}  # snake_case
resource "talos_machine_config" "worker" {}
```

### Output Names

```hcl
output "kubeconfig" {}
output "control_plane_ips" {}  # snake_case
```

## Talos Conventions

### Machine Configs

| Pattern | Example |
|---------|---------|
| `<role>-<index>` | `controlplane-0`, `worker-1` |

### Patches

| Pattern | Example |
|---------|---------|
| `<purpose>.yaml` | `cilium-inline.yaml` |
