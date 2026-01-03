# Memory Files

Memory files provide persistent context for Claude Code skills. They contain current infrastructure state, past decisions, and troubleshooting history.

## Purpose

- Provide context without re-querying infrastructure
- Record decisions and their rationale
- Track past issues and solutions
- Document component ownership

## Files

| File | Purpose | Update Frequency |
|------|---------|------------------|
| `current-state.md` | Live infrastructure state | After any change |
| `architecture-decisions.md` | ADRs and design choices | As decisions are made |
| `troubleshooting-history.md` | Past issues and solutions | After resolving issues |
| `component-ownership.md` | Who owns what | As ownership changes |
| `naming-conventions.md` | Standards reference | Rarely |

## Usage in Skills

Skills reference memory files for context:

```markdown
## Memory Files

Read these files for current context:
- `meta/memory/current-state.md` - Live infrastructure state
```

## Updating Memory

### Manual Update

Edit files directly after infrastructure changes:

```bash
vim meta/memory/current-state.md
```

### Automated Sync

Use the sync script to update from cluster state:

```bash
./scripts/sync-memory.sh
```

## Best Practices

1. **Keep current-state.md accurate** - Update after every infrastructure change
2. **Document troubleshooting** - Record issues and solutions for future reference
3. **Be specific** - Include versions, IPs, and concrete details
4. **Date entries** - Timestamp changes for history tracking
