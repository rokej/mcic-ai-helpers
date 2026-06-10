# MCIC conventions (shared reference)

Embedded in every workflow prompt under `prompts/`. If reading from disk:

- `/workspace/mcic-ai-helpers/prompts/_mcic-conventions.md`
- `/workspace/mcic-ai-helpers/docs/mcic-conventions.md` (mirror)

Do **not** use `docs/_mcic-conventions.md` — that path does not exist.

## Repositories

| Path | GitHub |
|------|--------|
| `/workspace/managedcluster-import-controller` | `stolostron/managedcluster-import-controller` |
| `/workspace/mcic-ai-helpers` | `rokej/mcic-ai-helpers` (required for conventions + `check_replied.py`) |

**Working directory:** `cd /workspace/managedcluster-import-controller` before `make`, `git`, or `gh`.

- Default branch: `main`
- Go module: `github.com/stolostron/managedcluster-import-controller`

## Jira (MCP only)

Use **Jira MCP tools** (`search_issues`, `get_issue`, `add_comment`, `update_issue`,
`transition_issue` or `transitionJiraIssue`). Do **not** use Jira CLI or direct REST/curl.

When picking up an issue to solve, transition status to **In Progress** before coding
(skip if already In Progress).

**Host:** `https://redhat.atlassian.net`
**Project:** ACM

### Agent queue JQL

```
project = ACM AND resolution = Unresolved AND status in (New, "To Do") AND labels = issue-for-agent AND labels != agent-processed ORDER BY created ASC
```

### Grooming

Issues need label `issue-for-agent`, status New or To Do, resolution Unresolved.
After successful solve, add label `agent-processed` via `update_issue`.

## Verification (required before commit / push)

```bash
source /workspace/mcic-ai-helpers/scripts/lib/go-env.sh
make check   # copyright + lint
make test    # full unit tests (envtest)
```

- Do **not** substitute `go test ./pkg/...` for `make test`
- E2E optional unless the issue explicitly requires it (`make e2e-test-core`)

## Commits

Conventional Commits + DCO sign-off:

```
fix(autoimport): short title

Explain why this change is needed.

Signed-off-by: Your Name <email@redhat.com>
```

Branch naming: `fix-ACM-12345` or `fix-ACM-12345-short-desc`

## Controller map (quick reference)

| Symptom | Look in |
|---------|---------|
| Import stuck | `pkg/controller/autoimport`, `csr`, `manifestwork`, `importconfig` |
| Detach/cleanup | `resourcecleanup`, `clusternamespacedeletion`, `managedcluster` |
| Hosted mode | `pkg/controller/hosted` |
| Hive import | `pkg/controller/clusterdeployment` |

Entry: `pkg/controller/controller.go` registers all controllers.

## E2E flakes

If touching `test/e2e` or klusterlet-agent lifecycle, read `test/e2e/README.md`
(leader-election after agent rollout).

## GitHub

- Use `gh` for PRs and review comments
- Draft PRs until a human marks ready
- PR title: `ACM-12345: summary`
- Footer: `🤖 Generated via mcic-ai-helpers agent-swarm`

## Automation footer for review replies

```
---
*AI-assisted response via agent-swarm*
```
