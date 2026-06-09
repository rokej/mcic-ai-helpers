#!/usr/bin/env bash
# Shared helpers for Jira MCP access in manual runner scripts.
#
# Agents and skills should call Jira by MCP *tool name* (search_issues, get_issue,
# etc.), not by a hardcoded server name. The server name varies by environment
# (e.g. jira-mcp-server, user-jira-mcp-server, Atlassian plugin MCP).
#
# Environment:
#   MCIC_SKIP_JIRA_MCP_SETUP=1  — do not write local .mcp.json Jira config or
#                                 require the pip-installed jira-mcp-server package;
#                                 use whatever Jira MCP the host already provides
#   JIRA_MCP_SERVER_NAME        — key in workspace .mcp.json when writing local
#                                 fallback (default: jira-mcp-server)
set -euo pipefail

JIRA_MCP_TOOLS="get_issue search_issues add_comment update_issue transition_issue"

jira_mcp_use_environment() {
  [[ "${MCIC_SKIP_JIRA_MCP_SETUP:-}" == "1" ]]
}

jira_mcp_local_available() {
  # shellcheck source=resolve-python.sh
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-python.sh"
  resolve_python || return 1
  "${MCIC_PYTHON}" -c "import jira_mcp_server" >/dev/null 2>&1
}

jira_mcp_credentials_set() {
  [[ -n "${JIRA_SERVER_URL:-}" && -n "${JIRA_EMAIL:-}" && -n "${JIRA_ACCESS_TOKEN:-}" ]]
}

# True when setup should write the pip-based jira-mcp-server block to .mcp.json.
jira_mcp_write_local_config() {
  if jira_mcp_use_environment; then
    return 1
  fi
  jira_mcp_local_available && jira_mcp_credentials_set
}

jira_mcp_status_line() {
  if jira_mcp_use_environment; then
    echo "Jira:      environment MCP (${JIRA_MCP_TOOLS})"
  elif jira_mcp_write_local_config; then
    echo "Jira:      local ${JIRA_MCP_SERVER_NAME:-jira-mcp-server} (${JIRA_MCP_TOOLS})"
  else
    echo "Jira:      environment MCP preferred; local fallback unavailable (${JIRA_MCP_TOOLS})"
  fi
}

jira_mcp_access_hint() {
  cat <<EOF
Use any available Jira MCP server. Call tools by name: ${JIRA_MCP_TOOLS}.
Do not use the Jira CLI or direct REST/curl.
EOF
}
