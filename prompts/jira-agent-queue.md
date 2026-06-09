# List MCIC Jira agent queue

List ACM issues groomed for the managedcluster-import-controller agent.
Equivalent to the HyperShift `periodic-jira-agent` JQL step (no solve).

## Instructions

1. Read shared conventions in `_mcic-conventions.md` (Jira MCP rules, agent JQL).

2. Call Jira MCP tool **`search_issues`** with:
   - `jql`: agent queue JQL from conventions (single line)
   - `max_results`: `20`

3. Present results as a table:

   | Key | Summary | Status | Created |

4. If **no results**:
   - Report queue is empty
   - Remind: add label `issue-for-agent`, status New/To Do, project ACM, no `agent-processed`

5. If **results found**:
   - Show total count
   - Note ordering: oldest first (`ORDER BY created ASC`)
   - List the first issue key as **next candidate** but do **not** implement or open a PR unless additional instructions ask you to solve it

## Do not

- Call Jira CLI or curl
- Modify issues or create PRs in this prompt
- Run `make check` / `make test` (no code changes)
