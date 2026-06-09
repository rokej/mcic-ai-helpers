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

  # jira-mcp-server reads .mcp.json from the project/workspace root.
  cp "${helpers_root}/plugins/jira/.mcp.json" "${mcp_file}"

  echo "Wrote ${settings_file}"
  echo "Wrote ${mcp_file} (jira-mcp-server)"
  echo "Plugins: jira@${marketplace_name}, mcic@${marketplace_name}, utils@${marketplace_name}"
}
