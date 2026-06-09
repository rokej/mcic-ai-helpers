---
name: mcic-build-test
description: Build and test commands for managedcluster-import-controller. Use when verifying changes, running CI locally, or choosing which make targets to run before commit or PR.
---

# MCIC build and test

Repository: `stolostron/managedcluster-import-controller`

## Required verification before commit/PR

Run **both** in order:

```bash
make check   # copyright headers + OCM lint
make test    # unit tests with envtest
```

Do **not** substitute `go test ./pkg/...` for `make test`. The Makefile runs the
full `GOPACKAGES` set with envtest setup and coverage.

## make check

| Target | What it runs |
|--------|--------------|
| `check-copyright` | `build/check-copyright.sh` — IBM/Red Hat copyright headers |
| `lint` | OCM sdk-go lint script (remote curl) |

## make test

- Runs `envtest-setup` first (downloads kubebuilder assets via OCM sdk-go script)
- `go clean -cache` workaround for Go 1.25 + CGO (see golang/go#69566)
- Tests all packages in `GOPACKAGES` (excludes manager, vendor, internal, build, test)

Unit tests live alongside controllers: `pkg/controller/<name>/*_test.go`

## Optional: build

```bash
make build   # cmd/manager + cmd/tls-profile-sync → _output/
```

Use when verifying compilation only; `make test` already compiles packages.

## E2E (optional — not required for most bug fixes)

E2E needs Kind, Helm, container image build. Only run when the issue requires it.

| Target | Ginkgo filter | Cluster setup |
|--------|---------------|---------------|
| `e2e-test-core` | `core && !agent-registration` | single Kind cluster |
| `e2e-test-misc` | `!core && !hosted && !agent-registration` | single |
| `e2e-test-hosted` | `hosted` | dual Kind clusters |
| `e2e-test-prow` | `agent-registration` | OCP/Prow only |

CI (GitHub Actions) runs `e2e-test-core`, `e2e-test-misc`, `e2e-test-hosted` in parallel.

## Failure handling

- If `make check` fails on copyright: ensure IBM/Red Hat header in new files (`build/copyright-header.txt`)
- If lint fails: fix reported issues; do not skip lint
- If `make test` fails: fix or confirm pre-existing; note pre-existing failures in PR description
- Never skip `make test` because lint had unrelated failures

## Anti-patterns

- Do NOT run only `go test ./pkg/controller/foo/`
- Do NOT use `go test` without envtest when controller tests need envtest
- Do NOT run full E2E for doc-only or narrow unit-test fixes
