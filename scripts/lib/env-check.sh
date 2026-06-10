#!/usr/bin/env bash
# Shared prerequisite checks for manual runner scripts.
set -euo pipefail

err() { echo "ERROR: $*" >&2; }

# shellcheck source=resolve-python.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/resolve-python.sh"

check_command() {
  local cmd="$1"
  local hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "$cmd is required. $hint"
    return 1
  fi
}

# shellcheck source=jira-mcp.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/jira-mcp.sh"

check_jira_mcp_server() {
  if jira_mcp_use_environment; then
    return 0
  fi

  if jira_mcp_write_local_config; then
    return 0
  fi

  resolve_python || return 1

  if ! jira_mcp_local_available; then
    err "No Jira MCP available for local Claude Code runs."
    err "Either:"
    err "  1. Install local fallback: ./scripts/setup-dev.sh"
    err "  2. Export JIRA_SERVER_URL, JIRA_EMAIL, JIRA_ACCESS_TOKEN for .mcp.json"
    err "  3. Set MCIC_SKIP_JIRA_MCP_SETUP=1 when the host already provides Jira MCP"
    err "See docs/jira-mcp-server-setup.md"
    return 1
  fi

  return 0
}

check_jira_env() {
  if jira_mcp_use_environment; then
    return 0
  fi

  if ! jira_mcp_write_local_config; then
    return 0
  fi

  local missing=0
  for var in JIRA_SERVER_URL JIRA_EMAIL JIRA_ACCESS_TOKEN; do
    if [[ -z "${!var:-}" ]]; then
      err "${var} is not set."
      missing=1
    fi
  done
  if [[ "${missing}" -ne 0 ]]; then
    err "Export Jira credentials for the local MCP fallback:"
    err '  export JIRA_SERVER_URL="https://redhat.atlassian.net"'
    err '  export JIRA_EMAIL="you@redhat.com"'
    err '  export JIRA_ACCESS_TOKEN="your-token"'
    err "Or set MCIC_SKIP_JIRA_MCP_SETUP=1 to use a host-provided Jira MCP."
    err "See docs/jira-mcp-server-setup.md"
    return 1
  fi
}

check_env() {
  local missing=0

  check_command git "Install git." || missing=1
  check_command gh "Run: gh auth login" || missing=1
  check_command claude "Install Claude Code: https://docs.anthropic.com/en/docs/claude-code" || missing=1

  if ! gh auth status >/dev/null 2>&1; then
    err "gh is not authenticated. Run: gh auth login"
    missing=1
  fi

  echo "=== Jira access ==="
  jira_mcp_access_hint
  echo ""

  check_jira_mcp_server || missing=1

  if [[ "${missing}" -ne 0 ]]; then
    exit 1
  fi

  echo "Prerequisites OK (claude, gh, git, ${MCIC_PYTHON:-n/a}, Jira MCP)"
}

check_env_with_jira() {
  check_env
  check_jira_env
}
