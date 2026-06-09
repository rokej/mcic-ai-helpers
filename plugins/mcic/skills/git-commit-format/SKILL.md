---
name: git-commit-format
description: Conventional commit and DCO sign-off rules for managedcluster-import-controller. Use when creating or amending commits.
---

# Git commit format (MCIC)

Repository uses **Conventional Commits** and **DCO Signed-off-by** (see `DCO` at repo root).

## Format

```
<type>(<scope>): <short description>

<body explaining why, not just what>

Signed-off-by: Name <email@example.com>
```

## Types

| Type | Use |
|------|-----|
| `fix` | Bug fixes |
| `feat` | New behavior |
| `test` | Test-only changes |
| `docs` | Documentation |
| `refactor` | No behavior change |
| `chore` | Maintenance, deps |

## Scopes (MCIC)

| Scope | Path |
|-------|------|
| `autoimport` | `pkg/controller/autoimport` |
| `managedcluster` | `pkg/controller/managedcluster` |
| `importconfig` | `pkg/controller/importconfig` |
| `csr` | `pkg/controller/csr` |
| `manifestwork` | `pkg/controller/manifestwork` |
| `hosted` | `pkg/controller/hosted` |
| `clusterdeployment` | `pkg/controller/clusterdeployment` |
| `helpers` | `pkg/helpers` |
| `e2e` | `test/e2e` |

Omit scope for cross-cutting changes if no single package dominates.

## Examples

```
fix(autoimport): retry secret lookup on transient failure

The autoimport controller could miss a newly created secret when the
informer lagged behind. Retry with backoff before marking import failed.

Signed-off-by: Jane Doe <jane@redhat.com>
```

```
test(importconfig): cover invalid klusterlet server URL revert

Signed-off-by: Jane Doe <jane@redhat.com>
```

## PR workflow

- Branch: `fix-ACM-12345` or `fix-ACM-12345-short-desc`
- **Default: amend** review fixes into the relevant commit (keep history clean)
- New commit only for substantial scope beyond original PR
- Push with `git push --force-with-lease` after amend

## Required

- **Signed-off-by** on every commit (DCO requirement)
- Body must explain **why**, not only what changed
