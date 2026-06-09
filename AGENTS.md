# AGENTS.md

Guidance for AI agents working in the **mcic-ai-helpers** repository.

## Repository purpose

This repo provides Claude Code marketplace plugins and manual runner scripts for
the Server Foundation team's managedcluster-import-controller (MCIC) automation.

## Hard rules

### Jira: jira-mcp-server only

All Jira operations MUST use **[jira-mcp-server](https://github.com/rokej/jira-mcp-server)**
MCP tools (server name: `jira-mcp-server`). Never use:

- `jira` CLI
- Direct `curl` / REST API calls to Jira from agent commands

Primary MCP tools:

| Operation | MCP tool |
|-----------|----------|
| Fetch issue | `get_issue` |
| Search queue | `search_issues` |
| Post comment | `add_comment` |
| Update labels/fields | `update_issue` |
| Transition status | `transition_issue` |

Credentials are configured in `.mcp.json` and loaded by jira-mcp-server:

- `JIRA_SERVER_URL` — e.g. `https://redhat.atlassian.net`
- `JIRA_EMAIL` — your Atlassian account email
- `JIRA_ACCESS_TOKEN` — API token from id.atlassian.com

See [docs/jira-mcp-server-setup.md](docs/jira-mcp-server-setup.md).

Install: `pip install git+https://github.com/rokej/jira-mcp-server.git`

### GitHub: gh CLI

Use `gh` for pull requests, review comments, and branch operations.

### Target repo conventions

When implementing fixes, follow MCIC conventions:

- `make check` — copyright + lint (required before commit)
- `make test` — unit tests with envtest (required before commit)
- E2E is optional for most bug fixes; run only when the issue requires it
- See `test/e2e/README.md` in MCIC for leader-election flake patterns

## Plugin layout

```
plugins/
  jira/     — /jira:solve + server-foundation skill + .mcp.json
  mcic/     — build, controllers, e2e, commit skills
  utils/    — /utils:address-reviews + mcic-pr-review skill
```

See [SKILLS.md](SKILLS.md) for the full index.

Commands are markdown specs consumed by Claude Code interactively or via
`claude -p` in manual runner scripts.

## What belongs here vs MCIC

| Here (mcic-ai-helpers) | MCIC repo (later) |
|------------------------|-------------------|
| Cross-cutting slash commands | Repo-specific skills (build, e2e flakes) |
| Jira team skill + `.mcp.json` template | `.claude/settings.json` marketplace wiring |
| Manual run scripts | `contrib/ai/local-runbook.md` pointer |
