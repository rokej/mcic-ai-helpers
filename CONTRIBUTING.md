# Contributing

## Adding commands

1. Add `plugins/<plugin>/commands/<name>.md` with frontmatter (`description`, `argument-hint`)
2. Register the plugin in `.claude-plugin/marketplace.json` if new
3. Document in `docs/manual-runbook.md`

## Jira commands

All Jira-related commands **must** use **[jira-mcp-server](https://github.com/rokej/jira-mcp-server)**
MCP tools (`get_issue`, `search_issues`, `add_comment`, `update_issue`, etc.).

Do not add:

- `jira` CLI references
- Direct `curl` REST examples in command specs

Credentials belong in `.mcp.json` / environment variables consumed by
jira-mcp-server — never hardcode tokens in command markdown.

## Testing locally

```bash
export JIRA_SERVER_URL="https://redhat.atlassian.net"
export JIRA_EMAIL="you@redhat.com"
export JIRA_ACCESS_TOKEN="your-token"

pip install git+https://github.com/rokej/jira-mcp-server.git

./scripts/run-jira-solve.sh ACM-XXXXX
```

## Scripts

- `scripts/run-jira-solve.sh` — end-to-end solve flow
- `scripts/run-address-reviews.sh` — PR review flow
- `scripts/list-jira-queue.sh` — prints JQL for `search_issues`

Make scripts executable: `make chmod-scripts`
