#!/usr/bin/env bash
# One-time dev setup: install local jira-mcp-server fallback for Claude Code CLI runs.
# Skip when the host already provides a Jira MCP (set MCIC_SKIP_JIRA_MCP_SETUP=1).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/resolve-python.sh
source "${SCRIPT_DIR}/lib/resolve-python.sh"
# shellcheck source=lib/jira-mcp.sh
source "${SCRIPT_DIR}/lib/jira-mcp.sh"

err() { echo "ERROR: $*" >&2; }

if jira_mcp_use_environment; then
  echo "MCIC_SKIP_JIRA_MCP_SETUP=1 — skipping local jira-mcp-server install."
  jira_mcp_access_hint
  exit 0
fi

resolve_python || exit 1

echo "Using Python: ${MCIC_PYTHON} ($("${MCIC_PYTHON}" --version))"

echo "Installing jira-mcp-server from github.com/rokej/jira-mcp-server ..."
"${MCIC_PYTHON}" -m pip install --upgrade 'git+https://github.com/rokej/jira-mcp-server.git'

echo ""
echo "Verifying import ..."
"${MCIC_PYTHON}" -c "import jira_mcp_server; print('jira_mcp_server OK')"

echo ""
echo "Next: export Jira credentials (see docs/jira-mcp-server-setup.md), then:"
echo "  ./scripts/run-jira-solve.sh ACM-XXXXX"
echo ""
echo "In Cursor or other hosts with Jira MCP already configured, you can instead set:"
echo "  export MCIC_SKIP_JIRA_MCP_SETUP=1"
