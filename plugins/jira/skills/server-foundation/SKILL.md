---
name: server-foundation-jira
description: Jira conventions for Server Foundation team work on managedcluster-import-controller. Use when creating, grooming, or solving ACM issues for MCIC.
---

# Server Foundation Jira conventions

## Project

- **Project key:** ACM (Red Hat Advanced Cluster Management)
- **Host:** `https://redhat.atlassian.net`
- **Component:** Multicluster Engine / import (match issue component when filing)

## jira-mcp-server access

All Jira operations use **[github.com/rokej/jira-mcp-server](https://github.com/rokej/jira-mcp-server)**
MCP tools (`get_issue`, `search_issues`, `add_comment`, `update_issue`).
Never use Jira CLI or direct REST/curl from agent commands.

Credentials: `JIRA_SERVER_URL`, `JIRA_EMAIL`, `JIRA_ACCESS_TOKEN` (see
[docs/jira-mcp-server-setup.md](../../../docs/jira-mcp-server-setup.md)).

## Issue grooming for agent processing

To mark an issue for the jira:solve workflow:

| Field | Value |
|-------|-------|
| Project | ACM |
| Status | New or To Do |
| Resolution | Unresolved |
| Label | `issue-for-agent` |
| Security | None |

After processing, add label `agent-processed` via `update_issue`.

## JQL: agent queue

See **`jira-agent-queue`** skill for listing issues with `search_issues`.

```
project = ACM
AND resolution = Unresolved
AND status in (New, "To Do")
AND labels = issue-for-agent
AND labels != agent-processed
ORDER BY created ASC
```

## Description template

```markdown
## Context
<why this matters, which controller/flow is affected>

## Acceptance criteria
- [ ] <measurable outcome>
- [ ] make check passes
- [ ] make test passes

## Steps to reproduce (bugs only)
1. ...

## Expected behavior
...

## Actual behavior
...
```

## Branch and PR naming

- Branch: `fix-ACM-12345` or `fix-ACM-12345-short-desc`
- PR title: `ACM-12345: <summary>`
- Always draft PR until a human marks ready for review

## Related repository

- GitHub: `stolostron/managedcluster-import-controller`
- Primary controllers: `pkg/controller/autoimport`, `hosted`, `csr`, `manifestwork`
