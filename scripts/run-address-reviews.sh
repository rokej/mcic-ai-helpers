#!/usr/bin/env bash
# Manual runner: address PR review comments on managedcluster-import-controller.
#
# Usage:
#   ./scripts/run-address-reviews.sh [PR_NUMBER] [--preview]
#
# GitHub access: gh CLI. No Jira involved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PR_NUMBER="${1:-}"
PREVIEW=""
MAX_TURNS="${MAX_TURNS:-100}"

for arg in "$@"; do
  if [[ "${arg}" == "--preview" ]]; then
    PREVIEW="--preview"
  fi
done

# shellcheck source=lib/env-check.sh
source "${SCRIPT_DIR}/lib/env-check.sh"
check_env

WORKSPACE_DIR="${ROOT_DIR}/.workspace/mcic"
export WORKSPACE_DIR
# shellcheck source=lib/clone-mcic.sh
source "${SCRIPT_DIR}/lib/clone-mcic.sh"
# shellcheck source=lib/setup-claude-plugins.sh
source "${SCRIPT_DIR}/lib/setup-claude-plugins.sh"
setup_claude_plugins "${WORKSPACE_DIR}" "${ROOT_DIR}"

cd "${WORKSPACE_DIR}"

if [[ -n "${PR_NUMBER}" && "${PR_NUMBER}" != "--preview" ]]; then
  echo "Checking out PR #${PR_NUMBER}..."
  gh pr checkout "${PR_NUMBER}" --repo stolostron/managedcluster-import-controller
fi

PROMPT="/utils:address-reviews"
if [[ -n "${PR_NUMBER}" && "${PR_NUMBER}" != "--preview" ]]; then
  PROMPT="${PROMPT} ${PR_NUMBER}"
fi
if [[ -n "${PREVIEW}" ]]; then
  PROMPT="${PROMPT} ${PREVIEW}"
fi

echo ""
echo "=== Running address-reviews ==="
echo "Workspace: ${WORKSPACE_DIR}"
echo "Command:   claude -p \"${PROMPT}\""
echo ""

claude -p "${PROMPT}" \
  --max-turns "${MAX_TURNS}" \
  --allowedTools "Bash Read Write Edit Grep Glob WebFetch"
