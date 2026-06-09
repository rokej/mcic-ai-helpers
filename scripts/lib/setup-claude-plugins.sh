#!/usr/bin/env bash
# Wire mcic-ai-helpers marketplace and jira-mcp-server MCP config into a workspace.

setup_claude_plugins() {
  local target_dir="$1"
  local helpers_root="$2"
  local settings_dir="${target_dir}/.claude"
  local settings_file="${settings_dir}/settings.json"
  local mcp_file="${target_dir}/.mcp.json"
  local marketplace_name="mcic-ai-helpers"
  local marketplace_path
  local python_bin

  # shellcheck source=resolve-python.sh
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-python.sh"
  resolve_python
  python_bin="${MCIC_PYTHON}"

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

  # Use resolved python3 path — macOS often lacks a `python` binary.
  cat > "${mcp_file}" <<EOF
{
  "mcpServers": {
    "jira-mcp-server": {
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

  echo "Wrote ${settings_file}"
  echo "Wrote ${mcp_file} (jira-mcp-server via ${python_bin})"
  echo "Plugins: jira@${marketplace_name}, mcic@${marketplace_name}, utils@${marketplace_name}"
}
