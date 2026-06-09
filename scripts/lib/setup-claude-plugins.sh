#!/usr/bin/env bash
# Wire mcic-ai-helpers marketplace into a target repo's .claude/settings.json.

setup_claude_plugins() {
  local target_dir="$1"
  local helpers_root="$2"
  local settings_dir="${target_dir}/.claude"
  local settings_file="${settings_dir}/settings.json"
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
    "utils@${marketplace_name}": true
  }
}
EOF

  if [[ -f "${helpers_root}/plugins/jira/.mcp.json" ]]; then
    cp "${helpers_root}/plugins/jira/.mcp.json" "${settings_dir}/.mcp.json"
  fi

  echo "Wrote ${settings_file}"
  echo "Plugins: jira@${marketplace_name}, utils@${marketplace_name}"
}
