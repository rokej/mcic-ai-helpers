---
name: mcic-controllers
description: managedcluster-import-controller architecture and controller map. Use when locating code for a bug, planning a fix, or understanding import/detach/hosted flows.
---

# MCIC controller architecture

The import controller runs on the **hub (management) cluster** and manages
spoke cluster import into Open Cluster Management.

Entry point: `cmd/manager/main.go` → `pkg/controller/controller.go` registers all controllers.

## Controller map

| Controller | Package | Responsibility |
|------------|---------|----------------|
| **autoimport** | `pkg/controller/autoimport` | Auto-import secrets → ManagedCluster import |
| **managedcluster** | `pkg/controller/managedcluster` | Core ManagedCluster lifecycle |
| **importconfig** | `pkg/controller/importconfig` | Import mode, KlusterletConfig, cluster info |
| **csr** | `pkg/controller/csr` | CSR approval for klusterlet bootstrap |
| **manifestwork** | `pkg/controller/manifestwork` | ManifestWork for klusterlet deployment |
| **importstatus** | `pkg/controller/importstatus` | Import condition/status reporting |
| **selfmanagedcluster** | `pkg/controller/selfmanagedcluster` | Local-cluster (self-managed) import |
| **clusterdeployment** | `pkg/controller/clusterdeployment` | Hive ClusterDeployment integration |
| **hosted** | `pkg/controller/hosted` | Hosted klusterlet mode (feature gate) |
| **clusternamespacedeletion** | `pkg/controller/clusternamespacedeletion` | Cleanup when cluster namespace deleted |
| **resourcecleanup** | `pkg/controller/resourcecleanup` | Orphan resource cleanup on detach |
| **flightctl** | `pkg/controller/flightctl` | FlightCtl device integration |

## Shared packages

| Path | Purpose |
|------|---------|
| `pkg/helpers/` | Client holders, cluster name helpers, shared utilities |
| `pkg/bootstrap/` | Bootstrap token, RBAC for import |
| `pkg/features/` | Feature gates (e.g. `KlusterletHostedMode`) |
| `pkg/source/` | Informer wiring |
| `deploy/` | Kustomize manifests for deployment |

## Common bug areas

| Symptom | Likely controllers |
|---------|-------------------|
| Import stuck / not joining | autoimport, csr, manifestwork, importconfig |
| Detach/cleanup incomplete | resourcecleanup, clusternamespacedeletion, managedcluster |
| Hosted cluster issues | hosted, importconfig |
| Hive cluster import | clusterdeployment |
| Status/conditions wrong | importstatus, managedcluster |
| KlusterletConfig changes | importconfig (`klusterletconfighandler.go`) |

## Testing

- Unit tests: `pkg/controller/<name>/*_test.go`
- E2E: `test/e2e/` with Ginkgo labels (`core`, `hosted`, etc.)
- See `mcic-e2e-flakes` skill when changing E2E or klusterlet-agent timing

## External dependencies

- OCM API: `open-cluster-management.io/api`
- Hive (ClusterDeployment): when clusterdeployment controller involved
- Does not run on spoke clusters — hub-side only
