# Manual runbook

Phase 1 runs AI-assisted workflows from your laptop. No Prow, no periodic jobs.

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| Claude Code | Runs slash commands | https://docs.anthropic.com/en/docs/claude-code |
| [jira-mcp-server](https://github.com/rokej/jira-mcp-server) | **All Jira access** | [setup guide](jira-mcp-server-setup.md) |
| `gh` | GitHub PRs and reviews | `gh auth login` |
| `git` | Clone MCIC | system package |
| `make` + Go | MCIC verification | MCIC dev environment |

## Jira access (jira-mcp-server)

> **Do not** use the Jira CLI or direct `curl` to Jira from agent commands.

This project uses **[github.com/rokej/jira-mcp-server](https://github.com/rokej/jira-mcp-server)**
(MCP server name: `jira-mcp-server`).

| Tool | Purpose |
|------|---------|
| `get_issue` | Fetch issue details |
| `search_issues` | Run JQL |
| `add_comment` | Post PR link |
| `update_issue` | Add labels |

### Setup

1. Install: `pip install git+https://github.com/rokej/jira-mcp-server.git`
2. Create API token: https://id.atlassian.com/manage-profile/security/api-tokens
3. Export credentials:

```bash
export JIRA_SERVER_URL="https://redhat.atlassian.net"
export JIRA_EMAIL="you@redhat.com"
export JIRA_ACCESS_TOKEN="your-token"
```

4. Verify: `claude mcp list` (should show `jira-mcp-server`)

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

All scripts clone MCIC to `.workspace/mcic` and write `.mcp.json` at the workspace root.

### Solve a Jira issue

```bash
export JIRA_SERVER_URL JIRA_EMAIL JIRA_ACCESS_TOKEN   # required

./scripts/run-jira-solve.sh ACM-12345
./scripts/run-jira-solve.sh ACM-12345 origin --ci   # non-interactive
```

What it does:

1. Validates Jira env vars and `gh` auth
2. Clones/updates `stolostron/managedcluster-import-controller`
3. Writes `.claude/settings.json` and `.mcp.json`
4. Runs `claude -p "/jira:solve ACM-12345 origin"`
5. Agent uses jira-mcp-server `get_issue`, implements fix, runs `make check` + `make test`
6. Creates a draft PR via `gh`

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

Uses the **`jira-agent-queue`** skill and jira-mcp-server `search_issues`.

## Interactive usage (without scripts)

In a MCIC clone with plugins and `.mcp.json` configured:

```
/jira:solve ACM-12345 origin
/utils:address-reviews 42 --preview
```

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `JIRA_SERVER_URL` | Yes (jira flows) | `https://redhat.atlassian.net` |
| `JIRA_EMAIL` | Yes (jira flows) | Atlassian account email |
| `JIRA_ACCESS_TOKEN` | Yes (jira flows) | API token for jira-mcp-server |
| `MAX_TURNS` | No | Claude turn limit (default `100`) |
| `MCIC_BRANCH` | No | Branch to clone (default `main`) |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `jira_mcp_server` module not found | `pip install git+https://github.com/rokej/jira-mcp-server.git` |
| Jira auth failure | Regenerate token; check email matches token owner |
| `claude mcp list` missing jira-mcp-server | Ensure `.mcp.json` in workspace root; check env vars |
| `gh auth` errors | `gh auth login` |
| `make test` fails | Fix in workspace; continue interactively |
