# mcic-ai-helpers

Claude Code plugins and manual runner scripts for AI-assisted development on
[stolostron/managedcluster-import-controller](https://github.com/stolostron/managedcluster-import-controller).

Phase 1 is **manual only** — run workflows from your laptop with Claude Code.
No Prow jobs yet.

## Design principles

- **Jira via [jira-mcp-server](https://github.com/rokej/jira-mcp-server)** — all
  Jira operations use MCP tools from `github.com/rokej/jira-mcp-server`. Do not
  use the Jira CLI or direct REST/curl from agent commands.
- **GitHub via `gh`** — PRs, review comments, and branch operations use the
  GitHub CLI.
- **Separate from MCIC** — agent building blocks live here; the target repo gets
  a small `.claude/settings.json` and `.mcp.json` when ready.

## Quick start

### Prerequisites

1. [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
2. [jira-mcp-server](https://github.com/rokej/jira-mcp-server) installed
3. Jira credentials exported — see [docs/jira-mcp-server-setup.md](docs/jira-mcp-server-setup.md)
4. `gh` authenticated (`gh auth login`)

```bash
pip install git+https://github.com/rokej/jira-mcp-server.git

export JIRA_SERVER_URL="https://redhat.atlassian.net"
export JIRA_EMAIL="you@redhat.com"
export JIRA_ACCESS_TOKEN="your-token"
```

### Install plugins (Claude Code)

```bash
/plugin marketplace add rokej/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers
/plugin install mcic@mcic-ai-helpers
/plugin install utils@mcic-ai-helpers
```

For local development:

```bash
/plugin marketplace add /path/to/mcic-ai-helpers
```

### Run manually

```bash
./scripts/run-jira-solve.sh ACM-12345
./scripts/run-address-reviews.sh 42 --preview
./scripts/list-jira-queue.sh
```

## Plugins

| Plugin | Commands / skills | Purpose |
|--------|-------------------|---------|
| `jira` | `/jira:solve`, `server-foundation` | Jira + issue solving |
| `mcic` | `mcic-build-test`, `mcic-controllers`, `mcic-e2e-flakes`, `git-commit-format` | MCIC codebase conventions |
| `utils` | `/utils:address-reviews`, `mcic-pr-review` | PR review handling |

See [SKILLS.md](SKILLS.md) for the full skill index.

## Documentation

- [jira-mcp-server setup](docs/jira-mcp-server-setup.md)
- [Manual runbook](docs/manual-runbook.md)
- [Jira issue grooming](docs/jira-issue-grooming.md)
- [MCP config example](examples/mcp.json.example)

## Target repository

- **Upstream:** `stolostron/managedcluster-import-controller`
- **Verification:** `make check`, `make test`
- **Jira project:** ACM

## Roadmap

- [x] Phase 1 — plugins + manual scripts (this repo)
- [ ] Phase 2 — `.claude/` skills in MCIC repo
- [ ] Phase 3 — Prow/ci-operator periodic jobs (openshift/release)
