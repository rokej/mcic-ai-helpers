---
description: Analyze an ACM Jira issue and create a draft pull request on managedcluster-import-controller.
argument-hint: "<jira-issue-key> [remote] [--ci]"
---

## Name
jira:solve

## Synopsis
```
/jira:solve <jira-issue-key> [remote] [--ci]
```

## Description

Analyze an ACM Jira issue and implement a fix in
`stolostron/managedcluster-import-controller`, then open a **draft** pull request.

**Usage examples:**

```
/jira:solve ACM-12345 origin
/jira:solve ACM-12345 origin --ci
```

---

## Jira integration (MCP only)

> **HARD RULE:** Use the **Atlassian Jira MCP server** for ALL Jira operations.
> Do NOT use the Jira CLI, `curl`, REST API calls, `JIRA_USERNAME`, or
> `JIRA_API_TOKEN`.

### Required MCP tools

| Step | MCP tool | Purpose |
|------|----------|---------|
| Resolve site | `getAccessibleAtlassianResources` | Get `cloudId` (or use `redhat.atlassian.net`) |
| Fetch issue | `getJiraIssue` | Summary, description, labels, components |
| Search queue | `searchJiraIssuesUsingJql` | Optional: find issues with `issue-for-agent` label |
| Post PR link | `addCommentToJiraIssue` | Link draft PR after creation |
| Mark processed | `editJiraIssue` | Add `agent-processed` label when done |

Use `responseContentFormat: markdown` when fetching descriptions.

### Forbidden patterns

```bash
# NEVER do any of these:
jira issue view ACM-12345
curl -u "$JIRA_USERNAME:$JIRA_API_TOKEN" https://redhat.atlassian.net/rest/api/3/issue/ACM-12345
```

---

## Target repository

- **Repo:** `stolostron/managedcluster-import-controller`
- **Default branch:** `main`
- **Module:** `github.com/stolostron/managedcluster-import-controller`

### Verification commands (required)

Run these before committing:

```bash
make check   # copyright + lint
make test    # unit tests (envtest)
```

Do NOT substitute `go test ./pkg/...` for `make test`.

E2E (`make e2e-test-core`) is optional unless the issue explicitly requires
integration coverage.

---

## Process flow

### 1. Issue analysis

Use `getJiraIssue` with `cloudId: redhat.atlassian.net` and the issue key from `$1`.

Extract from the description:

- **Required:** Context, Acceptance criteria
- **Optional:** Steps to reproduce, Expected vs actual behavior

If `--ci` is NOT set and required sections are missing, ask the user to groom
the issue before proceeding.

If `--ci` IS set, proceed with available information and note assumptions in the
PR description.

### 2. Codebase analysis

Search MCIC for relevant code:

- Controllers in `pkg/controller/`
- Helpers in `pkg/helpers/`, `pkg/bootstrap/`
- Tests alongside changed packages
- E2E tests in `test/e2e/` when behavior spans controllers

Use Grep and Glob. Read `test/e2e/README.md` if touching klusterlet-agent or
ManagedCluster lifecycle tests (leader-election race patterns).

### 3. Solution implementation

1. Save a plan to `.work/jira/solve/spec-<KEY>.md`
2. If `--ci` is NOT set: ask user to review the plan before coding
3. If `--ci` IS set: implement immediately
4. Follow existing patterns; add unit tests for new behavior
5. Run `make check` and `make test` — fix failures caused by your changes

### 4. Commit creation

- Branch name: `fix-<KEY>` (e.g. `fix-ACM-12345`)
- Use [Conventional Commits](https://www.conventionalcommits.org/) with a body
  explaining **why**
- Logical groupings:
  - `fix(controller):` — controller logic in `pkg/controller/`
  - `fix(helpers):` — shared helpers
  - `test:` — test additions
  - `docs:` — documentation in `docs/`

### 5. PR creation

- Push to remote `$2` (default: `origin`)
- Create **draft** PR against `stolostron/managedcluster-import-controller` `main`
- Title: `ACM-12345: <short summary>`
- Description must include:
  - Link to Jira issue
  - Summary of changes
  - Test plan (`make check`, `make test` results)
  - `🤖 Generated with Claude Code via /jira:solve`

```bash
gh pr create --draft --title "ACM-12345: ..." --body "..."
```

### 6. Jira follow-up (optional in phase 1)

After PR creation, use MCP to:

1. `addCommentToJiraIssue` — post PR URL
2. `editJiraIssue` — add label `agent-processed` (if requested by user)

---

## Arguments

- `$1`: Jira issue key (required, e.g. `ACM-12345`)
- `$2`: Git remote to push (default: `origin`)
- `$3`: Optional `--ci` flag — skip interactive prompts
