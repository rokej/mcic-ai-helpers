# Contributing

## Adding skills

Add `plugins/<plugin>/skills/<skill-name>/SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: When to auto-invoke this skill (be specific).
---
```

Register new plugins in `.claude-plugin/marketplace.json` and update [SKILLS.md](SKILLS.md).

## Adding commands

1. Add `plugins/<plugin>/commands/<name>.md` with frontmatter (`description`, `argument-hint`)
2. Register the plugin in `.claude-plugin/marketplace.json` if new
3. Document in `docs/manual-runbook.md`

## Jira commands

All Jira-related commands **must** use **Jira MCP tools** (`get_issue`,
`search_issues`, `add_comment`, `update_issue`, etc.) from whichever Jira MCP
server is available in the environment.

Do not add:

- `jira` CLI references
- Direct `curl` REST examples in command specs
- Hardcoded MCP server names (use tool names instead)

Credentials belong in environment variables or host MCP config — never hardcode
tokens in command markdown.

## Testing locally

**With host Jira MCP (Cursor, etc.):**

```bash
export MCIC_SKIP_JIRA_MCP_SETUP=1
./scripts/run-jira-solve.sh ACM-XXXXX
```

**With local Claude Code CLI fallback:**

```bash
export JIRA_SERVER_URL="https://redhat.atlassian.net"
export JIRA_EMAIL="you@redhat.com"
export JIRA_ACCESS_TOKEN="your-token"

./scripts/setup-dev.sh
./scripts/run-jira-solve.sh ACM-XXXXX
```

## Scripts

- `scripts/run-jira-solve.sh` — end-to-end solve flow
- `scripts/run-address-reviews.sh` — PR review flow
- `scripts/list-jira-queue.sh` — prints JQL for `search_issues`

Make scripts executable: `make chmod-scripts`
