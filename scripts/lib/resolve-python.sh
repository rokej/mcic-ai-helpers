#!/usr/bin/env bash
# Resolve Python 3 for local jira-mcp-server fallback (macOS often has python3 but not python).

resolve_python() {
  if [[ -n "${MCIC_PYTHON:-}" ]] && command -v "${MCIC_PYTHON}" >/dev/null 2>&1; then
    MCIC_PYTHON="$(command -v "${MCIC_PYTHON}")"
  elif command -v python3 >/dev/null 2>&1; then
    MCIC_PYTHON="$(command -v python3)"
  elif command -v python >/dev/null 2>&1; then
    MCIC_PYTHON="$(command -v python)"
  else
    err "Python 3.10+ is required. Install Python 3 or set MCIC_PYTHON to your interpreter."
    return 1
  fi

  export MCIC_PYTHON

  if ! "${MCIC_PYTHON}" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
    err "Python 3.10+ is required. Found: $("${MCIC_PYTHON}" --version 2>&1)"
    return 1
  fi
}
