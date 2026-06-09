---
name: server-foundation-jira
description: Jira conventions for Server Foundation team work on managedcluster-import-controller. Use when creating, grooming, or solving ACM issues for MCIC.
---

# Server Foundation Jira conventions

## Project

- **Project key:** ACM (Red Hat Advanced Cluster Management)
- **Host:** `https://redhat.atlassian.net`
- **Component:** Multicluster Engine / import (match issue component when filing)

## Jira MCP access

All Jira operations use **MCP tools** from whichever Jira MCP server is
available in the environment. Do not assume a specific server name.

| Operation | MCP tool |
|-----------|----------|
| Fetch issue | `get_issue` |
| Search queue | `search_issues` |
| Post comment | `add_comment` |
| Update labels/fields | `update_issue` |
| Transition status | `transition_issue` |

Never use Jira CLI or direct REST/curl from agent commands.

**Local fallback (Claude Code CLI):** [jira-mcp-server](https://github.com/rokej/jira-mcp-server)
with `JIRA_SERVER_URL`, `JIRA_EMAIL`, `JIRA_ACCESS_TOKEN` — see
[docs/jira-mcp-server-setup.md](../../../docs/jira-mcp-server-setup.md).

**IDE / platform hosts:** use the Jira MCP already configured (Cursor, Ambient,
Atlassian plugin, etc.).

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
