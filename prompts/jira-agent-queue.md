# List MCIC Jira agent queue

List ACM issues groomed for the managedcluster-import-controller agent.
Equivalent to the HyperShift `periodic-jira-agent` JQL step (no solve).

## MCIC conventions

**Jira:** MCP `search_issues` only — no Jira CLI or curl. **Agent queue JQL:**

```
project = ACM AND resolution = Unresolved AND status in (New, "To Do") AND labels = issue-for-agent AND labels != agent-processed ORDER BY created ASC
```

## Instructions

1. Call Jira MCP tool **`search_issues`** with:
   - `jql`: agent queue JQL above (single line)
   - `max_results`: `20`

2. Present results as a table:

   | Key | Summary | Status | Created |

3. If **no results**:
   - Report queue is empty
   - Remind: add label `issue-for-agent`, status New/To Do, project ACM, no `agent-processed`

4. If **results found**:
   - Show total count
   - Note ordering: oldest first (`ORDER BY created ASC`)
   - List the first issue key as **next candidate** but do **not** implement or open a PR unless additional instructions ask you to solve it

## Do not

- Call Jira CLI or curl
- Modify issues or create PRs in this prompt
- Run `make check` / `make test` (no code changes)
