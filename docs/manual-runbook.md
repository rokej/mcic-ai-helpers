# Manual runbook

Phase 1 runs AI-assisted workflows from your laptop. No Prow, no periodic jobs.

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| Claude Code | Runs slash commands | https://docs.anthropic.com/en/docs/claude-code |
| Atlassian MCP | **All Jira access** | Cursor Atlassian plugin or jira plugin `.mcp.json` |
| `gh` | GitHub PRs and reviews | `gh auth login` |
| `git` | Clone MCIC | system package |
| `make` + Go | MCIC verification | MCIC dev environment |

## Jira access (MCP only)

> **Do not** install the Jira CLI or set `JIRA_API_TOKEN`.

This project uses the **Atlassian Jira MCP server** for every Jira operation:

- Fetch issues (`getJiraIssue`)
- Search queue (`searchJiraIssuesUsingJql`)
- Update labels (`editJiraIssue`)
- Post comments (`addCommentToJiraIssue`)

### Cursor

1. Enable the Atlassian plugin (provides Jira MCP)
2. Complete OAuth when prompted
3. Verify: ask Claude to fetch an ACM issue via MCP

### Claude Code

1. Install plugins from this repo (see below)
2. The `jira` plugin ships `.mcp.json` pointing at Atlassian MCP
3. Complete MCP OAuth on first Jira tool use

## Install plugins

### From GitHub (after publishing)

```bash
/plugin marketplace add rokej/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers
/plugin install utils@mcic-ai-helpers
```

### Local development

```bash
/plugin marketplace add /path/to/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers
/plugin install utils@mcic-ai-helpers
```

## Manual scripts

All scripts live in `scripts/` and clone MCIC to `.workspace/mcic`.

### Solve a Jira issue

```bash
./scripts/run-jira-solve.sh ACM-12345
./scripts/run-jira-solve.sh ACM-12345 origin --ci   # non-interactive
```

What it does:

1. Clones/updates `stolostron/managedcluster-import-controller`
2. Writes `.claude/settings.json` with local marketplace
3. Runs `claude -p "/jira:solve ACM-12345 origin"`
4. Agent uses **MCP** to fetch the issue, implements fix, runs `make check` + `make test`
5. Creates a draft PR via `gh`

### Address review comments

```bash
./scripts/run-address-reviews.sh 42 --preview
./scripts/run-address-reviews.sh              # uses current branch
```

Uses `gh` only (no Jira). `--preview` confirms each action before executing.

### List agent queue

```bash
./scripts/list-jira-queue.sh
```

Prints JQL. Execute the search via Claude + Atlassian MCP (not CLI).

## Interactive usage (without scripts)

In a MCIC clone with plugins installed:

```
/jira:solve ACM-12345 origin
/utils:address-reviews 42 --preview
```

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MAX_TURNS` | `100` | Claude agentic turn limit |
| `MCIC_BRANCH` | `main` | Branch to clone |
| `MCIC_REPO` | stolostron/managedcluster-import-controller | Clone URL |

**Not used:** `JIRA_USERNAME`, `JIRA_API_TOKEN`

## Troubleshooting

| Problem | Fix |
|---------|-----|
| MCP auth fails | Re-authenticate Atlassian plugin; check VPN if required |
| `claude: command not found` | Install Claude Code CLI |
| `gh auth` errors | `gh auth login` |
| `make test` fails in agent run | Fix in workspace; re-run or continue interactively |
| Plugin not found | Check marketplace path in `.claude/settings.json` |
