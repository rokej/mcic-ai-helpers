# mcic-ai-helpers

Claude Code plugins and manual runner scripts for AI-assisted development on
[stolostron/managedcluster-import-controller](https://github.com/stolostron/managedcluster-import-controller).

Phase 1 is **manual only** — run workflows from your laptop with Claude Code or
Cursor. No Prow jobs yet.

## Design principles

- **Jira via MCP only** — use the Atlassian Jira MCP server for all Jira reads
  and writes. Do not use the Jira CLI, `curl`, or `JIRA_API_TOKEN`.
- **GitHub via `gh`** — PRs, review comments, and branch operations use the
  GitHub CLI.
- **Separate from MCIC** — agent building blocks live here; the target repo gets
  a small `.claude/settings.json` when ready.

## Quick start

### Prerequisites

1. [Claude Code](https://docs.anthropic.com/en/docs/claude-code) or Cursor with
   the Atlassian plugin
2. **Atlassian MCP authenticated** (browser OAuth) — see
   [docs/manual-runbook.md](docs/manual-runbook.md)
3. `gh` authenticated (`gh auth login`)
4. `git` and `make` (for MCIC verification)

### Install plugins (Claude Code)

```bash
/plugin marketplace add rokej/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers
/plugin install utils@mcic-ai-helpers
```

For local development before publishing:

```bash
/plugin marketplace add /path/to/mcic-ai-helpers
```

### Run manually

```bash
# Solve a Jira issue → branch + draft PR on MCIC
./scripts/run-jira-solve.sh ACM-12345

# Address review comments on a PR (--preview recommended)
./scripts/run-address-reviews.sh 42 --preview

# List issues ready for the agent (prints JQL; run via Claude MCP)
./scripts/list-jira-queue.sh
```

## Plugins

| Plugin | Commands | Purpose |
|--------|----------|---------|
| `jira` | `/jira:solve` | Fetch issue via MCP, implement fix, open draft PR |
| `utils` | `/utils:address-reviews` | Triage and address PR review comments |

## Documentation

- [Manual runbook](docs/manual-runbook.md) — setup, env checks, examples
- [Jira issue grooming](docs/jira-issue-grooming.md) — labels and JQL criteria
- [MCIC `.claude/settings.json` example](examples/mcic-claude-settings.json)

## Target repository

- **Upstream:** `stolostron/managedcluster-import-controller`
- **Verification:** `make check`, `make test`
- **Jira project:** ACM (Red Hat Advanced Cluster Management)

## Roadmap

- [x] Phase 1 — plugins + manual scripts (this repo)
- [ ] Phase 2 — `.claude/` skills in MCIC repo
- [ ] Phase 3 — Prow/ci-operator periodic jobs (openshift/release)
