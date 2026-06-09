#!/usr/bin/env bash
# Manual runner: solve an ACM Jira issue on managedcluster-import-controller.
#
# Usage:
#   ./scripts/run-jira-solve.sh ACM-12345 [remote] [--ci]
#
# Jira access: github.com/rokej/jira-mcp-server MCP only (no Jira CLI, no direct curl).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ISSUE_KEY="${1:-}"
REMOTE="${2:-origin}"
CI_FLAG=""
MAX_TURNS="${MAX_TURNS:-100}"

if [[ -z "${ISSUE_KEY}" ]]; then
  echo "Usage: $0 <JIRA-KEY> [remote] [--ci]" >&2
  echo "Example: $0 ACM-12345 origin" >&2
  exit 1
fi

if [[ "${REMOTE}" == "--ci" ]]; then
  CI_FLAG="--ci"
  REMOTE="origin"
elif [[ "${3:-}" == "--ci" ]]; then
  CI_FLAG="--ci"
fi

# shellcheck source=lib/env-check.sh
source "${SCRIPT_DIR}/lib/env-check.sh"
check_env_with_jira

WORKSPACE_DIR="${ROOT_DIR}/.workspace/mcic"
export WORKSPACE_DIR
# shellcheck source=lib/clone-mcic.sh
source "${SCRIPT_DIR}/lib/clone-mcic.sh"
# shellcheck source=lib/setup-claude-plugins.sh
source "${SCRIPT_DIR}/lib/setup-claude-plugins.sh"
setup_claude_plugins "${WORKSPACE_DIR}" "${ROOT_DIR}"

cd "${WORKSPACE_DIR}"

PROMPT="/jira:solve ${ISSUE_KEY} ${REMOTE}"
if [[ -n "${CI_FLAG}" ]]; then
  PROMPT="${PROMPT} ${CI_FLAG}"
fi

echo ""
echo "=== Running jira:solve ==="
echo "Issue:     ${ISSUE_KEY}"
echo "Remote:    ${REMOTE}"
echo "Workspace: ${WORKSPACE_DIR}"
echo "Jira:      github.com/rokej/jira-mcp-server (get_issue, search_issues)"
echo ""
echo "Command:   claude -p \"${PROMPT}\""
echo ""

claude -p "${PROMPT}" \
  --max-turns "${MAX_TURNS}" \
  --allowedTools "Bash Read Write Edit Grep Glob WebFetch"
