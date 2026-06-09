# AGENTS.md

Guidance for AI agents working in the **mcic-ai-helpers** repository.

## Repository purpose

This repo provides Claude Code marketplace plugins and manual runner scripts for
the Server Foundation team's managedcluster-import-controller (MCIC) automation.

## Hard rules

### Jira: MCP only

All Jira operations MUST use the **Atlassian Jira MCP server**. Never use:

- `jira` CLI
- `curl` / REST API calls to `redhat.atlassian.net`
- `JIRA_USERNAME` / `JIRA_API_TOKEN` environment variables

Use these MCP tools instead:

| Operation | MCP tool |
|-----------|----------|
| Fetch issue | `getJiraIssue` |
| Search queue | `searchJiraIssuesUsingJql` |
| Update fields/labels | `editJiraIssue` |
| Transition status | `getTransitionsForJiraIssue`, `transitionJiraIssue` |
| Add comment | `addCommentToJiraIssue` |
| Resolve cloud ID | `getAccessibleAtlassianResources` |

`cloudId` may be `redhat.atlassian.net`.

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
  jira/     — /jira:solve command + server-foundation Jira skill
  utils/    — /utils:address-reviews command + check_replied.py
```

Commands are markdown specs consumed by Claude Code interactively or via
`claude -p` in manual runner scripts.

## What belongs here vs MCIC

| Here (mcic-ai-helpers) | MCIC repo (later) |
|------------------------|-------------------|
| Cross-cutting slash commands | Repo-specific skills (build, e2e flakes) |
| Jira team skill | `.claude/settings.json` marketplace wiring |
| Manual run scripts | `contrib/ai/local-runbook.md` pointer |
