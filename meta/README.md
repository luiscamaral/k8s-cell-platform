# Meta Layer - Cross-Layer Orchestration

The `meta/` directory provides cross-layer orchestration, version management, and context for AI assistants.

## Purpose

- **Version Control**: Track compatible versions across all layers
- **Interface Contracts**: Define dependencies between layers
- **Memory/Context**: Provide persistent context for Claude Code skills
- **Integration Testing**: Validate cross-layer functionality

## Directory Structure

```
meta/
├── README.md               # This file
├── Makefile                # Cross-layer operations
├── versions.yaml           # Version compatibility matrix
│
├── contracts/              # Layer interface definitions
│   ├── l0-provides.yaml    # What L0 outputs
│   ├── l1-requires.yaml    # What L1 needs from L0
│   ├── l1-provides.yaml    # What L1 outputs
│   └── l2-requires.yaml    # What L2 needs from L1
│
├── memory/                 # AI context files
│   ├── README.md           # How to use memory files
│   ├── current-state.md    # Live infrastructure state
│   ├── architecture-decisions.md
│   ├── troubleshooting-history.md
│   ├── component-ownership.md
│   └── naming-conventions.md
│
├── docs/                   # Cross-layer documentation
│   ├── getting-started.md
│   ├── architecture-overview.md
│   └── deployment-flow.md
│
├── integration-tests/      # Cross-layer validation
│   ├── test-l0-l1.sh
│   └── test-l1-l2.sh
│
└── scripts/                # Orchestration utilities
    ├── check-versions.sh
    └── sync-memory.sh
```

## Quick Start

### Check Platform Status

```bash
make status
```

### Validate Versions

```bash
make check-versions
```

### Run Integration Tests

```bash
make test-integration
```

## Memory Files

Memory files provide context to Claude Code skills. They should be kept up-to-date as infrastructure changes.

### Updating Memory

After infrastructure changes:

```bash
# Manual update
vim meta/memory/current-state.md

# Or use the sync script
./scripts/sync-memory.sh
```

### Memory File Usage

Skills read memory files for context:

```markdown
## Memory Files

Read for context:
- `meta/memory/current-state.md` - Current infrastructure state
```

## Version Management

`versions.yaml` tracks compatible versions across all layers:

```yaml
layers:
  l0_infrastructure:
    version: "1.0.0"
    components:
      talos: "1.11.5"

  l1_cluster_platform:
    version: "1.0.0"
    requires:
      l0_infrastructure: ">=1.0.0"
```

## Contracts

Contracts define explicit interfaces between layers:

- **provides**: What a layer outputs
- **requires**: What a layer needs from previous layers

This enables:
- Dependency validation
- Upgrade safety checks
- Clear documentation of interfaces
