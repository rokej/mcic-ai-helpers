# jira-mcp-server setup

All Jira access uses **[jira-mcp-server](https://github.com/rokej/jira-mcp-server)** —
a stdio MCP server for Jira Cloud. Do not use the Jira CLI or direct `curl` calls
from agent commands.

## Install

```bash
pip install git+https://github.com/rokej/jira-mcp-server.git
```

Or from a local clone:

```bash
git clone https://github.com/rokej/jira-mcp-server.git
cd jira-mcp-server
pip install -e .
```

Verify:

```bash
python -c "import jira_mcp_server; print('ok')"
```

Use the same Python interpreter in `.mcp.json` if `python` is not on your PATH
(e.g. `/path/to/venv/bin/python`).

Optional: set `cwd` in `.mcp.json` to your jira-mcp-server clone if you use a
`.env` file there instead of exported variables.

## Credentials

Create an API token at https://id.atlassian.com/manage-profile/security/api-tokens

Export before running manual scripts:

```bash
export JIRA_SERVER_URL="https://redhat.atlassian.net"
export JIRA_EMAIL="you@redhat.com"
export JIRA_ACCESS_TOKEN="your-token"
```

Never commit tokens. Use `examples/mcp.json.example` as a template.

## MCP configuration

MCP server name: **`jira-mcp-server`**

```json
{
  "mcpServers": {
    "jira-mcp-server": {
      "command": "python",
      "args": ["-m", "jira_mcp_server.main"],
      "env": {
        "JIRA_SERVER_URL": "${JIRA_SERVER_URL}",
        "JIRA_ACCESS_TOKEN": "${JIRA_ACCESS_TOKEN}",
        "JIRA_EMAIL": "${JIRA_EMAIL}"
      }
    }
  }
}
```

`run-jira-solve.sh` writes this to the MCIC workspace root as `.mcp.json`.

Verify in Claude Code:

```bash
claude mcp list
```

## MCP tools used by mcic-ai-helpers

| Tool | Purpose |
|------|---------|
| `get_issue` | Fetch issue by key (e.g. `ACM-12345`) |
| `search_issues` | Run JQL queries |
| `add_comment` | Post PR link after solve |
| `update_issue` | Add `agent-processed` label |

See the [full tool list](https://github.com/rokej/jira-mcp-server#available-tools)
for create, transition, linking, and team features.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ModuleNotFoundError: jira_mcp_server` | Install from github.com/rokej/jira-mcp-server; use full python path |
| Auth failure | Regenerate token; check `JIRA_EMAIL` matches token owner |
| Server not listed | Ensure `.mcp.json` in workspace root; `claude mcp list` |
