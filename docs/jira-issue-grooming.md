# Jira issue grooming

How to prepare ACM issues for the `jira:solve` agent workflow.

## Eligibility

| Field | Required value |
|-------|----------------|
| Project | ACM |
| Status | New or To Do |
| Resolution | Unresolved |
| Label | `issue-for-agent` |
| Security | None |

## While processing

When the agent picks up an issue, it transitions status to **In Progress** via MCP
(`transition_issue` / `transitionJiraIssue`) before implementing.

## After processing

Add label `agent-processed` via Jira MCP tool `update_issue`, or
manually in Jira.

To reprocess: remove `agent-processed` and ensure `issue-for-agent` is present.

## JQL: agent queue

```
project = ACM
AND resolution = Unresolved
AND status in (New, "To Do")
AND labels = issue-for-agent
AND labels != agent-processed
ORDER BY created ASC
```

Search with Jira MCP tool `search_issues` (see **`jira-agent-queue`** skill).

## Description template

```markdown
## Context
The autoimport controller fails when ... (which file/flow in pkg/controller/)

## Acceptance criteria
- [ ] Root cause fixed in managedcluster-import-controller
- [ ] Unit test added or updated
- [ ] make check passes
- [ ] make test passes

## Steps to reproduce
1. Create ManagedCluster with ...
2. Observe ...

## Expected behavior
Import completes and klusterlet becomes available.

## Actual behavior
ManagedCluster stays in Unknown state with condition ...
```

## Scope guidance

Good candidates:

- Unit-testable controller bugs
- Clear acceptance criteria
- Changes confined to MCIC

Poor candidates (defer to humans):

- Multi-repo changes across OCM + MCIC + addon-framework
- Requires live cluster reproduction only
- Security-sensitive credential handling
