# mcic-ai-helpers

Claude Code plugins and manual runner scripts for AI-assisted development on
[stolostron/managedcluster-import-controller](https://github.com/stolostron/managedcluster-import-controller).

Phase 1 is **manual only** — run workflows from your laptop with Claude Code.
No Prow jobs yet.

## Design principles

- **Jira via MCP tools** — use whichever Jira MCP server is available in the
  environment (`search_issues`, `get_issue`, etc.). Do not use the Jira CLI or
  direct REST/curl from agent commands. Local CLI fallback:
  [jira-mcp-server](https://github.com/rokej/jira-mcp-server).
- **GitHub via `gh`** — PRs, review comments, and branch operations use the
  GitHub CLI.
- **Separate from MCIC** — agent building blocks live here; the target repo gets
  a small `.claude/settings.json` and `.mcp.json` when ready.

## Quick start

### Prerequisites

1. [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
2. Jira MCP — host-provided (Cursor, etc.) **or** local fallback via
   [jira-mcp-server](https://github.com/rokej/jira-mcp-server) — see
   [docs/jira-mcp-server-setup.md](docs/jira-mcp-server-setup.md)
3. `gh` authenticated (`gh auth login`)

```bash
# Host Jira MCP (e.g. Cursor):
export MCIC_SKIP_JIRA_MCP_SETUP=1

# Local CLI fallback:
./scripts/setup-dev.sh
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

## Agent-swarm prompts (phase 3)

Model-agnostic workflows in [`prompts/`](prompts/) for
[agent-swarm](https://github.com/rokej/agent-swarm) (OpenCode/Crush), synced via
Prompt Source — same role as HyperShift periodic Jira/review agents, without Prow.

| Prompt | Purpose |
|--------|---------|
| `jira-agent-pipeline.md` | Query queue → solve one issue → draft PR |
| `jira-agent-queue.md` | List groomed queue only |
| `jira-solve.md` | Solve a single issue key |
| `address-reviews-batch.md` | Batch agent PR reviews |
| `address-reviews.md` | Single PR review handling |

Setup: [docs/agent-swarm-setup.md](docs/agent-swarm-setup.md)

## Documentation

- [Agent-swarm setup](docs/agent-swarm-setup.md)
- [Jira MCP setup](docs/jira-mcp-server-setup.md)
- [Manual runbook](docs/manual-runbook.md)
- [Jira issue grooming](docs/jira-issue-grooming.md)
- [MCP config example](examples/mcp.json.example)

## Target repository

- **Upstream:** `stolostron/managedcluster-import-controller`
- **Verification:** `make check`, `make test`
- **Jira project:** ACM

## Roadmap

- [x] Phase 1 — plugins + manual scripts (this repo)
- [x] Phase 3a — `prompts/` for agent-swarm (this repo)
- [ ] Phase 2 — `.claude/` wiring in MCIC repo (`contrib/ai/`)
- [ ] Phase 3b — agent-swarm workspace sessions + cron (operator setup)
