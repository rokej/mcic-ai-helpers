---
name: jira-agent-queue
description: List unresolved ACM Jira issues ready for the MCIC agent using search_issues. Use when asked to list the agent queue, find issue-for-agent tickets, show pending Jira work, or pick the next issue to solve.
---

# Jira agent queue listing

Lists issues eligible for `/jira:solve` on managedcluster-import-controller —
equivalent to the HyperShift `periodic-jira-agent` JQL query step (manual phase 1).

## Jira access (any MCP server)

Use whichever **Jira MCP server** is available in the environment. Do **not**
assume a specific server name — it varies (e.g. `jira-mcp-server`,
`user-jira-mcp-server`, Atlassian plugin MCP).

Identify Jira access by **tool name**: call MCP tool **`search_issues`**.

Do **not** use Jira CLI, `curl`, or direct REST API calls.

## Agent queue JQL

```
project = ACM
AND resolution = Unresolved
AND status in (New, "To Do")
AND labels = issue-for-agent
AND labels != agent-processed
ORDER BY created ASC
```

This matches issues groomed per `docs/jira-issue-grooming.md`.

## How to list issues

1. Call **`search_issues`** (via any available Jira MCP server) with:
   - `jql`: the query above (single line is fine)
   - `max_results`: `20` for listing; `1` when picking the next issue only

2. Parse the response and present a table:

   | Key | Summary | Status | Created |
   |-----|---------|--------|---------|

3. If **no results**: report that the queue is empty and remind the user how to
   groom an issue (`issue-for-agent` label, New/To Do, ACM project).

4. If **results found**: show count and note the **oldest first** (`ORDER BY created ASC`).

## Picking the next issue

When asked for the **next** issue to process (not just a list):

1. Run `search_issues` with `max_results: 1` and the same JQL
2. Return the first issue key (e.g. `ACM-33390`)
3. Optionally offer to run `/jira:solve <KEY> origin`

Do not call `/jira:solve` automatically unless the user asks to process the issue.

## Eligibility criteria (reference)

| Field | Required |
|-------|----------|
| Project | ACM |
| Resolution | Unresolved |
| Status | New or To Do |
| Label | `issue-for-agent` |
| Must not have | `agent-processed` label |

## After an issue is processed

Issues leave the queue when label **`agent-processed`** is added (via MCP
`update_issue` after a successful solve, or manually in Jira).

To reprocess: remove `agent-processed`, keep `issue-for-agent`.

## Related

- Grooming: `server-foundation-jira` skill, `docs/jira-issue-grooming.md`
- Solve: `/jira:solve <KEY> [remote] [--ci]`
- Shell helper (prints JQL only): `scripts/list-jira-queue.sh`
