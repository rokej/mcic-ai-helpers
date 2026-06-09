#!/usr/bin/env bash
# Print the JQL for the agent issue queue and instructions to list via MCP.
#
# This script does NOT call Jira CLI or REST. Use Claude Code with Atlassian MCP
# to execute the search interactively.
set -euo pipefail

JQL='project = ACM AND resolution = Unresolved AND status in (New, "To Do") AND labels = issue-for-agent AND labels != agent-processed ORDER BY created ASC'

cat <<EOF
=== MCIC agent issue queue ===

JQL:
  ${JQL}

To list issues, run in Claude Code (with jira@mcic-ai-helpers installed):

  Use the Atlassian MCP tool searchJiraIssuesUsingJql with:
    cloudId: redhat.atlassian.net
    jql: ${JQL}

Or ask Claude:

  "Search Jira with MCP for issues matching the agent queue JQL and list keys + summaries"

Do NOT use: jira CLI, curl, or JIRA_API_TOKEN.
EOF
