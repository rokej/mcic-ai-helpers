# Jira MCP setup

All Jira access uses **MCP tools** — never the Jira CLI or direct `curl`/REST
from agent commands.

## Environment-first (recommended in IDE hosts)

In Cursor, Ambient, or other hosts with Jira MCP already configured, use that
server directly. Identify Jira access by **tool name**:

| Tool | Purpose |
|------|---------|
| `get_issue` | Fetch issue by key (e.g. `ACM-12345`) |
| `search_issues` | Run JQL queries |
| `add_comment` | Post PR link after solve |
| `update_issue` | Add `agent-processed` label |

The server name varies by host (`user-jira-mcp-server`, Atlassian plugin MCP,
`jira-mcp-server`, etc.) — agents should not assume a specific name.

For manual runner scripts in these environments:

```bash
export MCIC_SKIP_JIRA_MCP_SETUP=1
./scripts/run-jira-solve.sh ACM-12345
./scripts/list-jira-queue.sh
```

## Local fallback (Claude Code CLI)

When running `claude -p` via manual scripts without a host-provided Jira MCP,
install **[jira-mcp-server](https://github.com/rokej/jira-mcp-server)**:

```bash
./scripts/setup-dev.sh
```

Or manually:

```bash
python3 -m pip install git+https://github.com/rokej/jira-mcp-server.git
```

On macOS, use `python3` — a `python` binary is often not on PATH. The manual
runner scripts resolve the interpreter automatically and write the full path
into the workspace `.mcp.json` when credentials are exported.

Optional: set `cwd` in `.mcp.json` to your jira-mcp-server clone if you use a
`.env` file there instead of exported variables.

### Credentials

Create an API token at https://id.atlassian.com/manage-profile/security/api-tokens

Export before running manual scripts:

```bash
export JIRA_SERVER_URL="https://redhat.atlassian.net"
export JIRA_EMAIL="you@redhat.com"
export JIRA_ACCESS_TOKEN="your-token"
```

Never commit tokens. Use `examples/mcp.json.example` as a template.

### Workspace `.mcp.json`

When local fallback is active (package installed + credentials set), scripts write:

```json
{
  "mcpServers": {
    "jira-mcp-server": {
      "command": "python3",
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

Override the server key with `JIRA_MCP_SERVER_NAME` if needed.

Verify in Claude Code:

```bash
claude mcp list
```

See the [full tool list](https://github.com/rokej/jira-mcp-server#available-tools)
for create, transition, linking, and team features.

## Environment variables

| Variable | Purpose |
|----------|---------|
| `JIRA_SERVER_URL` | Atlassian instance URL (local fallback) |
| `JIRA_EMAIL` | Account email (local fallback) |
| `JIRA_ACCESS_TOKEN` | API token (local fallback) |
| `MCIC_SKIP_JIRA_MCP_SETUP` | `1` — skip local `.mcp.json` Jira config; use host MCP |
| `JIRA_MCP_SERVER_NAME` | Key in workspace `.mcp.json` (default: `jira-mcp-server`) |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ModuleNotFoundError: jira_mcp_server` | Run `./scripts/setup-dev.sh`, or set `MCIC_SKIP_JIRA_MCP_SETUP=1` |
| Auth failure | Regenerate token; check `JIRA_EMAIL` matches token owner |
| No Jira MCP in CLI run | Export credentials for local fallback, or use host MCP with skip flag |
| Wrong server name in IDE | Ignore — call tools by name (`search_issues`, etc.) |
