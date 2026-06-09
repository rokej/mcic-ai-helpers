# Contributing

## Adding commands

1. Add `plugins/<plugin>/commands/<name>.md` with frontmatter (`description`, `argument-hint`)
2. Register the plugin in `.claude-plugin/marketplace.json` if new
3. Document in `docs/manual-runbook.md`

## Jira commands

All Jira-related commands **must** use Atlassian MCP tools. Do not add:

- `jira` CLI references
- `curl` REST examples
- `JIRA_API_TOKEN` requirements

## Testing locally

```bash
# Install plugins from this directory
/plugin marketplace add /path/to/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers

# Run manual script
./scripts/run-jira-solve.sh ACM-XXXXX
```

## Scripts

- `scripts/run-jira-solve.sh` — end-to-end solve flow
- `scripts/run-address-reviews.sh` — PR review flow
- `scripts/list-jira-queue.sh` — prints JQL (MCP execution only)

Make scripts executable after clone: `chmod +x scripts/*.sh scripts/lib/*.sh`
