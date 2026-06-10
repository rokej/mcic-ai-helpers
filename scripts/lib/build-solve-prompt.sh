#!/usr/bin/env bash
# Build a non-interactive prompt for run-jira-solve.sh (no slash-command dependency).

build_solve_prompt() {
  local issue_key="$1"
  local remote="$2"
  local ci_flag="$3"
  local workspace_dir="$4"
  local helpers_root="$5"
  local solve_spec="${helpers_root}/plugins/jira/commands/solve.md"
  local mode="non-interactive (implement immediately, no plan approval)"

  if [[ -z "${ci_flag}" ]]; then
    mode="interactive (may ask for plan approval)"
  fi

  cat <<EOF
Execute the MCIC Jira solve workflow defined in:
${solve_spec}

Parameters:
- issue_key: ${issue_key}
- remote: ${remote}
- mode: ${mode}

Working directory (MCIC clone): ${workspace_dir}
Plugin skills: ${helpers_root}/plugins/

Hard rules:
- Jira MCP tools only (${JIRA_MCP_TOOLS})
- Before make check/test: source ${helpers_root}/scripts/lib/go-env.sh
- Run make check then make test sequentially (NOT parallel); shell timeout ≥ 900000 ms for make check
- make check can be silent for several minutes — do not assume stuck until 15+ min
- Draft PR only; do not mark ready for review
- If issue already has label agent-processed or an open PR for this key, report and stop
EOF
}
