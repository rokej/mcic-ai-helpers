#!/usr/bin/env bash
# Shared prerequisite checks for manual runner scripts.
set -euo pipefail

err() { echo "ERROR: $*" >&2; }

check_command() {
  local cmd="$1"
  local hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "$cmd is required. $hint"
    return 1
  fi
}

check_jira_mcp_server() {
  if ! python -c "import jira_mcp_server" >/dev/null 2>&1; then
    err "jira-mcp-server is not installed."
    err "Install: pip install git+https://github.com/rokej/jira-mcp-server.git"
    return 1
  fi
}

check_jira_env() {
  local missing=0
  for var in JIRA_SERVER_URL JIRA_EMAIL JIRA_ACCESS_TOKEN; do
    if [[ -z "${!var:-}" ]]; then
      err "${var} is not set."
      missing=1
    fi
  done
  if [[ "${missing}" -ne 0 ]]; then
    err "Export Jira credentials for jira-mcp-server:"
    err '  export JIRA_SERVER_URL="https://redhat.atlassian.net"'
    err '  export JIRA_EMAIL="you@redhat.com"'
    err '  export JIRA_ACCESS_TOKEN="your-token"'
    err "See docs/jira-mcp-server-setup.md"
    return 1
  fi
}

check_env() {
  local missing=0

  check_command git "Install git." || missing=1
  check_command gh "Run: gh auth login" || missing=1
  check_command claude "Install Claude Code: https://docs.anthropic.com/en/docs/claude-code" || missing=1
  check_command python "Install Python 3.10+" || missing=1

  if ! gh auth status >/dev/null 2>&1; then
    err "gh is not authenticated. Run: gh auth login"
    missing=1
  fi

  echo "=== Jira access ==="
  echo "This project uses github.com/rokej/jira-mcp-server MCP tools ONLY."
  echo "Do NOT use jira CLI or direct curl to Jira."
  echo ""

  check_jira_mcp_server || missing=1

  if [[ "${missing}" -ne 0 ]]; then
    exit 1
  fi

  echo "Prerequisites OK (claude, gh, git, python, jira-mcp-server)"
}

check_env_with_jira() {
  check_env
  check_jira_env
}
