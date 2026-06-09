#!/usr/bin/env bash
# Print the JQL for the agent issue queue and instructions to search via jira-mcp-server.
#
# Uses github.com/rokej/jira-mcp-server — not Jira CLI or direct REST.
set -euo pipefail

JQL='project = ACM AND resolution = Unresolved AND status in (New, "To Do") AND labels = issue-for-agent AND labels != agent-processed ORDER BY created ASC'

cat <<EOF
=== MCIC agent issue queue ===

JQL:
  ${JQL}

To list issues, use jira-mcp-server (github.com/rokej/jira-mcp-server)
MCP tool search_issues:

  jql: ${JQL}
  max_results: 20

Or ask Claude (with jira-mcp-server configured):

  "Use search_issues to list ACM issues matching the agent queue JQL"

Requires JIRA_SERVER_URL, JIRA_EMAIL, JIRA_ACCESS_TOKEN
See docs/jira-mcp-server-setup.md

Do NOT use: jira CLI or curl to Jira REST.
EOF
