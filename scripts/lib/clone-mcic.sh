#!/usr/bin/env bash
# Clone or update managedcluster-import-controller into a workspace directory.
set -euo pipefail

MCIC_REPO="${MCIC_REPO:-https://github.com/stolostron/managedcluster-import-controller.git}"
MCIC_BRANCH="${MCIC_BRANCH:-main}"
WORKSPACE_DIR="${WORKSPACE_DIR:-}"

if [[ -z "${WORKSPACE_DIR}" ]]; then
  echo "WORKSPACE_DIR is required" >&2
  exit 1
fi

if [[ -d "${WORKSPACE_DIR}/.git" ]]; then
  echo "Updating existing clone at ${WORKSPACE_DIR}..."
  git -C "${WORKSPACE_DIR}" fetch origin
  git -C "${WORKSPACE_DIR}" checkout "${MCIC_BRANCH}"
  git -C "${WORKSPACE_DIR}" pull --rebase origin "${MCIC_BRANCH}"
else
  echo "Cloning ${MCIC_REPO} → ${WORKSPACE_DIR}..."
  git clone --branch "${MCIC_BRANCH}" "${MCIC_REPO}" "${WORKSPACE_DIR}"
fi

echo "MCIC ready at ${WORKSPACE_DIR}"
