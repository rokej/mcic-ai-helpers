#!/usr/bin/env bash
# Run MCIC verification with writable Go caches (agent-swarm safe).
#
# Usage:
#   ./scripts/verify-mcic.sh [check|test|all]
#
# MCIC_REPO defaults to .workspace/mcic for local runs, or
# /workspace/managedcluster-import-controller in agent-swarm.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/go-env.sh
source "${SCRIPT_DIR}/lib/go-env.sh"

TARGET="${1:-all}"
MCIC_REPO="${MCIC_REPO:-/workspace/managedcluster-import-controller}"

if [[ ! -d "${MCIC_REPO}" ]]; then
  MCIC_REPO="${SCRIPT_DIR}/../.workspace/mcic"
fi

if [[ ! -f "${MCIC_REPO}/Makefile" ]]; then
  echo "ERROR: MCIC repo not found at ${MCIC_REPO}" >&2
  exit 1
fi

cd "${MCIC_REPO}"
echo "=== MCIC verify (GOMODCACHE=${GOMODCACHE}) ==="

run_check() {
  make check
}

run_test() {
  make test
}

case "${TARGET}" in
  check) run_check ;;
  test)  run_test ;;
  all)   run_check; run_test ;;
  *)
    echo "Usage: $0 [check|test|all]" >&2
    exit 1
    ;;
esac

echo "=== OK ==="
