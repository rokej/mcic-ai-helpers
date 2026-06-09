#!/usr/bin/env bash
# Wire mcic-ai-helpers marketplace and optional local Jira MCP config into a workspace.

setup_claude_plugins() {
  local target_dir="$1"
  local helpers_root="$2"
  local settings_dir="${target_dir}/.claude"
  local settings_file="${settings_dir}/settings.json"
  local mcp_file="${target_dir}/.mcp.json"
  local marketplace_name="mcic-ai-helpers"
  local marketplace_path
  local python_bin
  local jira_server_name

  # shellcheck source=resolve-python.sh
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-python.sh"
  # shellcheck source=jira-mcp.sh
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/jira-mcp.sh"

  resolve_python
  python_bin="${MCIC_PYTHON}"
  jira_server_name="${JIRA_MCP_SERVER_NAME:-jira-mcp-server}"

  marketplace_path="$(cd "${helpers_root}" && pwd)"

  mkdir -p "${settings_dir}"

  cat > "${settings_file}" <<EOF
{
  "extraKnownMarketplaces": {
    "${marketplace_name}": {
      "source": {
        "source": "directory",
        "path": "${marketplace_path}"
      }
    }
  },
  "enabledPlugins": {
    "jira@${marketplace_name}": true,
    "mcic@${marketplace_name}": true,
    "utils@${marketplace_name}": true
  }
}
EOF

  if jira_mcp_write_local_config; then
    # Local fallback for Claude Code CLI when no host-provided Jira MCP exists.
    cat > "${mcp_file}" <<EOF
{
  "mcpServers": {
    "${jira_server_name}": {
      "command": "${python_bin}",
      "args": ["-m", "jira_mcp_server.main"],
      "env": {
        "JIRA_SERVER_URL": "\${JIRA_SERVER_URL}",
        "JIRA_ACCESS_TOKEN": "\${JIRA_ACCESS_TOKEN}",
        "JIRA_EMAIL": "\${JIRA_EMAIL}"
      }
    }
  }
}
EOF
    echo "Wrote ${mcp_file} (local ${jira_server_name} via ${python_bin})"
  else
    cat > "${mcp_file}" <<EOF
{
  "mcpServers": {}
}
EOF
    if jira_mcp_use_environment; then
      echo "Wrote ${mcp_file} (empty — using environment Jira MCP; MCIC_SKIP_JIRA_MCP_SETUP=1)"
    else
      echo "Wrote ${mcp_file} (empty — configure a Jira MCP in the host or run ./scripts/setup-dev.sh)"
    fi
  fi

  echo "Wrote ${settings_file}"
  echo "Plugins: jira@${marketplace_name}, mcic@${marketplace_name}, utils@${marketplace_name}"
}
