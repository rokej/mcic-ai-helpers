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
  echo "This project uses the Atlassian Jira MCP server ONLY."
  echo "Do NOT use jira CLI or JIRA_API_TOKEN."
  echo ""
  echo "Before running jira:* commands, ensure Atlassian MCP is authenticated:"
  echo "  - Cursor: enable the Atlassian plugin and complete OAuth"
  echo "  - Claude Code: install jira@mcic-ai-helpers (includes .mcp.json)"
  echo ""

  if [[ "${missing}" -ne 0 ]]; then
    exit 1
  fi

  echo "Prerequisites OK (claude, gh, git)"
}
