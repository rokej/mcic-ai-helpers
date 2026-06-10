#!/usr/bin/env bash
# Manual runner: solve an ACM Jira issue on managedcluster-import-controller.
#
# Usage:
#   ./scripts/run-jira-solve.sh ACM-12345 [remote] [--ci]
#
# Defaults to non-interactive (--ci) so claude -p does not wait for plan approval.
# Set MCIC_INTERACTIVE=1 to allow interactive plan review in solve.md.
#
# Jira access: any configured Jira MCP server (no Jira CLI, no direct curl).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=lib/jira-mcp.sh
source "${SCRIPT_DIR}/lib/jira-mcp.sh"

ISSUE_KEY="${1:-}"
REMOTE="${2:-origin}"
CI_FLAG=""
MAX_TURNS="${MAX_TURNS:-100}"
PERMISSION_MODE="${MCIC_PERMISSION_MODE:-dontAsk}"

# Non-interactive script: default --ci so claude -p does not wait for plan approval.
if [[ "${MCIC_INTERACTIVE:-}" != "1" ]]; then
  CI_FLAG="--ci"
fi

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

# Writable Go caches for make check/test.
# shellcheck source=lib/go-env.sh
source "${SCRIPT_DIR}/lib/go-env.sh"
export GOMODCACHE GOCACHE GOPATH

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

SETTINGS_FILE="${WORKSPACE_DIR}/.claude/settings.json"
MCP_FILE="${WORKSPACE_DIR}/.mcp.json"

# shellcheck source=lib/build-solve-prompt.sh
source "${SCRIPT_DIR}/lib/build-solve-prompt.sh"
PROMPT="$(build_solve_prompt "${ISSUE_KEY}" "${REMOTE}" "${CI_FLAG}" "${WORKSPACE_DIR}" "${ROOT_DIR}")"

CLAUDE_ARGS=(
  -p "${PROMPT}"
  --max-turns "${MAX_TURNS}"
  --settings "${SETTINGS_FILE}"
  --setting-sources "project,local"
  --permission-mode "${PERMISSION_MODE}"
  --add-dir "${ROOT_DIR}"
  --allowedTools "Bash Read Write Edit Grep Glob WebFetch"
)

# Load workspace MCP when local jira-mcp-server is configured.
if [[ -f "${MCP_FILE}" ]] && grep -q '"command"' "${MCP_FILE}" 2>/dev/null; then
  CLAUDE_ARGS+=(--mcp-config "${MCP_FILE}")
fi

echo ""
echo "=== Running jira:solve ==="
echo "Issue:     ${ISSUE_KEY}"
echo "Remote:    ${REMOTE}"
echo "Workspace: ${WORKSPACE_DIR}"
jira_mcp_status_line
echo ""
echo "Mode:      ${CI_FLAG:-interactive (MCIC_INTERACTIVE=1)}"
echo "Max turns: ${MAX_TURNS}"
echo "Spec:      ${ROOT_DIR}/plugins/jira/commands/solve.md"
echo ""

claude "${CLAUDE_ARGS[@]}"
