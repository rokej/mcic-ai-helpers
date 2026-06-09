---
name: mcic-e2e-flakes
description: E2E test flake patterns and leader-election rules for managedcluster-import-controller. Use when writing or fixing tests in test/e2e or debugging klusterlet-agent timing failures.
---

# MCIC E2E flake patterns

Source of truth in repo: `test/e2e/README.md`

## Rule: leader election after klusterlet-agent rollout

Any test step that triggers a **klusterlet-agent deployment rollout** must wait
for leader election before steps that depend on a functional agent (e.g.
deleting ManagedCluster).

### Why

Initial import always triggers a rolling update:

1. Import controller creates klusterlet deployment
2. ~4s later CSR approval updates the spec → rolling update
3. Old pod may have set `Available=True` before termination
4. New pod still doing leader election → race if test proceeds

### Race if ignored

1. Test deletes ManagedCluster while new pod waits for lease
2. `orphanCleanup()` removes ManifestWorks and `workRoleBinding`
3. New work agent gets 403 listing ManifestWorks
4. Finalizers block namespace deletion → timeout

## Protected helpers (automatic checks)

These call leader-election logic internally:

| Helper | When |
|--------|------|
| `assertManagedClusterDeleted()` | Before AfterEach cleanup delete |
| `assertManagedClusterAvailable()` | Before availability check |
| `assertManagedClusterOffline()` | Before offline check |

Each helper: deletes agent pods, deletes `klusterlet-agent-lock` lease, calls
`assertAgentLeaderElection()`.

## When to call `assertAgentLeaderElection()` explicitly

Only when the test deletes ManagedCluster in the **test body** (not AfterEach):

- `cleanup_test.go` — all cases
- `clusterdeployment_test.go` — destroy/detach tests

## assertAgentLeaderElection behavior

1. List klusterlet-agent pods; ignore Terminating pods
2. Wait for exactly one non-terminating pod
3. Verify `klusterlet-agent-lock` lease holder matches pod name
4. Timeout: **180 seconds** (non-graceful worst case ~163s)

## Leader election timing

| Parameter | Value |
|-----------|-------|
| Lease duration | 137s |
| Renew deadline | 107s |
| Retry period | 26s |

## Other E2E notes

- **klusterletconfig_test.go**: call `restartAgentPods()` after reverting invalid
  server URL (escape CrashLoopBackOff)
- Tolerate `NotFound` in `restartAgentPods()` when pod already deleted by rollout

## E2E labels (CI split)

| Label | Job |
|-------|-----|
| `core` | `make e2e-test-core` |
| `hosted` | `make e2e-test-hosted` |
| (neither core nor hosted) | `make e2e-test-misc` |
| `agent-registration` | `make e2e-test-prow` only |

When fixing E2E, run the matching target — full `e2e-test` is slow and rarely needed locally.
