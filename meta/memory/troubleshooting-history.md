# Troubleshooting History

Record of past issues and their solutions. Used by troubleshooting skills for context.

---

## Issue: Cilium Pods Not Starting After Bootstrap

**Date**: 2024-11-20
**Layer**: L0
**Severity**: Critical

### Symptoms
- Cilium pods stuck in Pending state
- All other pods waiting for CNI

### Root Cause
Cilium was deployed via kubectl after bootstrap, causing race condition with kube-proxy.

### Solution
Moved Cilium deployment to Talos inline manifests for bootstrap-time installation.

### Prevention
Always deploy CNI via Talos inline manifests, not post-bootstrap.

---

## Issue: MetalLB Speaker Pods CrashLoopBackOff

**Date**: 2024-11-25
**Layer**: L1
**Severity**: High

### Symptoms
- MetalLB speaker pods crashing
- LoadBalancer services stuck Pending
- Error: "failed to get node IP"

### Root Cause
Speaker pods unable to determine node IPs due to network configuration.

### Solution
Updated MetalLB configuration to use correct network interface.

### Prevention
Verify network interface names before deploying MetalLB.

---

## Issue: External-DNS Not Creating Records

**Date**: 2024-12-01
**Layer**: L1
**Severity**: Medium

### Symptoms
- Services with DNS annotations not getting records
- external-dns logs showing "no endpoints"

### Root Cause
Pi-hole provider requires specific API endpoint format.

### Solution
Updated external-dns deployment with correct Pi-hole API configuration.

### Prevention
Test external-dns with a simple service before full deployment.

---

## Issue: Karpenter Not Provisioning Nodes

**Date**: 2024-12-02
**Layer**: L1
**Severity**: High

### Symptoms
- Pending pods not triggering node provisioning
- Karpenter logs showing "no matching instance types"

### Root Cause
NodePool configuration missing Proxmox-specific settings.

### Solution
Updated NodePool with Proxmox provider configuration.

### Prevention
Use Proxmox-specific NodePool templates.

---

## Issue: Kyverno Image Pull Errors

**Date**: 2024-12-05
**Layer**: L2
**Severity**: Medium

### Symptoms
- Kyverno pods in ImagePullBackOff
- Error: "rate limit exceeded"

### Root Cause
Docker Hub rate limiting for anonymous pulls.

### Solution
Configured image pull from ghcr.io instead of Docker Hub.

### Runbook
See `l2_core-platform/docs/runbooks/KYVERNO_IMAGE_PULL_ISSUE.md`

---

## Template for New Issues

```markdown
## Issue: [Brief Title]

**Date**: YYYY-MM-DD
**Layer**: L0/L1/L2/etc
**Severity**: Critical/High/Medium/Low

### Symptoms
- What was observed

### Root Cause
Why it happened

### Solution
How it was fixed

### Prevention
How to avoid in future
```
