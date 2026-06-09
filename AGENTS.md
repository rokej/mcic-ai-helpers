# AGENTS.md

Guidance for AI agents working in the **mcic-ai-helpers** repository.

## Repository purpose

This repo provides Claude Code marketplace plugins and manual runner scripts for
the Server Foundation team's managedcluster-import-controller (MCIC) automation.

## Hard rules

### Jira: MCP tools (any configured server)

All Jira operations MUST use **Jira MCP tools** from whichever Jira MCP server
is available in the environment. Do not assume a specific server name
(`jira-mcp-server`, `user-jira-mcp-server`, Atlassian plugin MCP, etc.).

Identify Jira access by **tool name**, not server name. Never use:

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

**Local CLI fallback:** [jira-mcp-server](https://github.com/rokej/jira-mcp-server)
installed via `./scripts/setup-dev.sh`, credentials in workspace `.mcp.json`.

**IDE / platform hosts:** use the Jira MCP already configured in the environment.
Set `MCIC_SKIP_JIRA_MCP_SETUP=1` for manual runner scripts when using host MCP.

See [docs/jira-mcp-server-setup.md](docs/jira-mcp-server-setup.md).

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

### Agent-swarm prompts

`prompts/` holds the same workflows as model-agnostic markdown for
[agent-swarm](https://github.com/rokej/agent-swarm) (OpenCode/Crush). Sync via
Prompt Source — see [prompts/README.md](prompts/README.md) and
[docs/agent-swarm-setup.md](docs/agent-swarm-setup.md).

| Claude Code | Agent-swarm prompt |
|-------------|-------------------|
| `/jira:solve` | `prompts/jira-solve.md` |
| `jira-agent-queue` skill | `prompts/jira-agent-queue.md` |
| periodic Jira agent | `prompts/jira-agent-pipeline.md` |
| `/utils:address-reviews` | `prompts/address-reviews.md` |
| periodic review agent | `prompts/address-reviews-batch.md` |

Shared conventions: `prompts/_mcic-conventions.md`

## What belongs here vs MCIC

| Here (mcic-ai-helpers) | MCIC repo (later) |
|------------------------|-------------------|
| Cross-cutting slash commands | Repo-specific skills (build, e2e flakes) |
| Jira team skill + `.mcp.json` template | `.claude/settings.json` marketplace wiring |
| Manual run scripts | `contrib/ai/local-runbook.md` pointer |
