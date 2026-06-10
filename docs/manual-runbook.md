# Manual runbook

Phase 1 runs AI-assisted workflows from your laptop. No Prow, no periodic jobs.

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| Claude Code | Runs slash commands | https://docs.anthropic.com/en/docs/claude-code |
| Jira MCP | **All Jira access** (any configured server) | [setup guide](jira-mcp-server-setup.md) |
| `gh` | GitHub PRs and reviews | `gh auth login` |
| `git` | Clone MCIC | system package |
| `make` + Go | MCIC verification | MCIC dev environment |

## Jira access (MCP tools)

> **Do not** use the Jira CLI or direct `curl` to Jira from agent commands.

Use whichever **Jira MCP server** is available in the environment. Call tools
by name — do not assume a specific server name.

| Tool | Purpose |
|------|---------|
| `get_issue` | Fetch issue details |
| `search_issues` | Run JQL |
| `add_comment` | Post PR link |
| `update_issue` | Add labels |

### Setup options

**Option A — host MCP (Cursor, Ambient, etc.):**

```bash
export MCIC_SKIP_JIRA_MCP_SETUP=1
```

**Option B — local Claude Code CLI fallback:**

1. Install: `./scripts/setup-dev.sh`
2. Create API token: https://id.atlassian.com/manage-profile/security/api-tokens
3. Export credentials:

```bash
export JIRA_SERVER_URL="https://redhat.atlassian.net"
export JIRA_EMAIL="you@redhat.com"
export JIRA_ACCESS_TOKEN="your-token"
```

4. Verify: `claude mcp list` (should show a Jira MCP server)

Full details: [jira-mcp-server-setup.md](jira-mcp-server-setup.md)

## Install plugins

### From GitHub

```bash
/plugin marketplace add rokej/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers
/plugin install mcic@mcic-ai-helpers
/plugin install utils@mcic-ai-helpers
```

### Local development

```bash
/plugin marketplace add /path/to/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers
/plugin install mcic@mcic-ai-helpers
/plugin install utils@mcic-ai-helpers
```

## Manual scripts

All scripts clone MCIC to `.workspace/mcic` and write `.mcp.json` at the workspace root
(local Jira MCP fallback only when credentials and package are available).

### Solve a Jira issue

```bash
export JIRA_SERVER_URL JIRA_EMAIL JIRA_ACCESS_TOKEN   # required for local fallback
# or: export MCIC_SKIP_JIRA_MCP_SETUP=1               # host-provided Jira MCP

./scripts/run-jira-solve.sh ACM-12345
./scripts/run-jira-solve.sh ACM-12345 origin --ci   # explicit non-interactive
```

Defaults to **non-interactive** (`--ci`) so `claude -p` does not wait for plan
approval. Set `MCIC_INTERACTIVE=1` for interactive plan review.

What it does:

1. Validates Jira MCP availability (host or local fallback) and `gh` auth
2. Clones/updates `stolostron/managedcluster-import-controller`
3. Writes `.claude/settings.json` and `.mcp.json` (optional local Jira MCP)
4. Runs `claude -p` with `plugins/jira/commands/solve.md` as the runbook
5. Agent uses Jira MCP `get_issue`, transitions to In Progress, runs `make check` + `make test`
6. Creates a draft PR via `gh`

**Troubleshooting:** If the run appears stuck, it is often `make check`/`make test`
(5–15+ minutes). `Unknown command: /jira:solve` means an old script — update mcic-ai-helpers.
For ACM-34995, PR [#1119](https://github.com/stolostron/managedcluster-import-controller/pull/1119)
already exists; the agent should report and stop.

### Address review comments

```bash
./scripts/run-address-reviews.sh 42 --preview
./scripts/run-address-reviews.sh              # uses current branch
```

Uses `gh` only (no Jira).

### List agent queue

```bash
./scripts/list-jira-queue.sh              # Claude lists queue via search_issues
./scripts/list-jira-queue.sh --jql-only   # print JQL only
```

Uses the **`jira-agent-queue`** skill and Jira MCP `search_issues`.

## Interactive usage (without scripts)

In a MCIC clone with plugins and `.mcp.json` configured:

```
/jira:solve ACM-12345 origin
/utils:address-reviews 42 --preview
```

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `JIRA_SERVER_URL` | Local fallback only | `https://redhat.atlassian.net` |
| `JIRA_EMAIL` | Local fallback only | Atlassian account email |
| `JIRA_ACCESS_TOKEN` | Local fallback only | API token for local jira-mcp-server |
| `MCIC_SKIP_JIRA_MCP_SETUP` | No | `1` — use host Jira MCP, skip local `.mcp.json` config |
| `JIRA_MCP_SERVER_NAME` | No | Key in workspace `.mcp.json` (default `jira-mcp-server`) |
| `MAX_TURNS` | No | Claude turn limit (default `100`) |
| `MCIC_BRANCH` | No | Branch to clone (default `main`) |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `jira_mcp_server` module not found | `./scripts/setup-dev.sh`, or `MCIC_SKIP_JIRA_MCP_SETUP=1` |
| Jira auth failure | Regenerate token; check email matches token owner |
| No Jira MCP in CLI run | Export credentials for local fallback, or use host MCP |
| `gh auth` errors | `gh auth login` |
| `make test` fails | Fix in workspace; continue interactively |
