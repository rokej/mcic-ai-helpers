#!/usr/bin/env bash
# One-time dev setup: install jira-mcp-server for manual runner scripts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/resolve-python.sh
source "${SCRIPT_DIR}/lib/resolve-python.sh"

err() { echo "ERROR: $*" >&2; }

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
