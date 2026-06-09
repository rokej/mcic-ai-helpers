#!/usr/bin/env bash
# Print agent-queue JQL and run Claude to list matching Jira issues via MCP.
#
# Usage:
#   ./scripts/list-jira-queue.sh           # invoke Claude to list queue
#   ./scripts/list-jira-queue.sh --jql-only  # print JQL only (no Claude)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=lib/jira-mcp.sh
source "${SCRIPT_DIR}/lib/jira-mcp.sh"

JQL='project = ACM AND resolution = Unresolved AND status in (New, "To Do") AND labels = issue-for-agent AND labels != agent-processed ORDER BY created ASC'

if [[ "${1:-}" == "--jql-only" ]]; then
  cat <<EOF
=== MCIC agent issue queue JQL ===

${JQL}

Use any available Jira MCP tool search_issues, or ask Claude (jira-agent-queue skill).
EOF
  exit 0
fi

# shellcheck source=lib/env-check.sh
source "${SCRIPT_DIR}/lib/env-check.sh"
check_env_with_jira

WORKSPACE_DIR="${ROOT_DIR}/.workspace/mcic-list"
export WORKSPACE_DIR
mkdir -p "${WORKSPACE_DIR}"

# shellcheck source=lib/setup-claude-plugins.sh
source "${SCRIPT_DIR}/lib/setup-claude-plugins.sh"
setup_claude_plugins "${WORKSPACE_DIR}" "${ROOT_DIR}"

cd "${WORKSPACE_DIR}"

PROMPT="Use the jira-agent-queue skill. Use any available Jira MCP server and call search_issues with this JQL. Present the results as a table of key, summary, status, and created date:

${JQL}

max_results: 20"

echo ""
echo "=== Listing Jira agent queue ==="
jira_mcp_status_line
echo ""

claude -p "${PROMPT}" \
  --max-turns "${MAX_TURNS:-30}" \
  --allowedTools "Bash Read Write Edit Grep Glob WebFetch"
