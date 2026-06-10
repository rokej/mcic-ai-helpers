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

## Jira integration (MCP tools only)

> **HARD RULE:** Use **Jira MCP tools** for ALL Jira reads and writes.
> Use whichever Jira MCP server is available in the environment — do not assume
> a specific server name.
> Do NOT use the Jira CLI or direct `curl`/REST calls from this command.

Authentication is handled by the configured Jira MCP server (via host credentials
or `JIRA_SERVER_URL`, `JIRA_EMAIL`, `JIRA_ACCESS_TOKEN` in workspace `.mcp.json`
for local CLI runs) — not by ad-hoc agent env vars.

### Required MCP tools

| Step | MCP tool | Purpose |
|------|----------|---------|
| Fetch issue | `get_issue` | Summary, description, status, labels |
| Search queue | `search_issues` | Find issues matching agent JQL |
| Start work | `transition_issue` | Move issue to **In Progress** when picked up |
| Post PR link | `add_comment` | Link draft PR after creation |
| Mark processed | `update_issue` | Add `agent-processed` label |

### Forbidden patterns

```bash
# NEVER do any of these from this command:
jira issue view ACM-12345
curl -H "Authorization: Bearer $JIRA_ACCESS_TOKEN" https://redhat.atlassian.net/rest/api/3/issue/ACM-12345
```

Use MCP tools `add_comment` and `update_issue` for Jira follow-up — not CLI/curl.

---

## Target repository

- **Repo:** `stolostron/managedcluster-import-controller`
- **Default branch:** `main`
- **Module:** `github.com/stolostron/managedcluster-import-controller`

### Applicable skills (mcic@mcic-ai-helpers)

| Skill | Use when |
|-------|----------|
| `mcic-controllers` | Locating code, understanding import flows |
| `mcic-build-test` | Verification (`make check`, `make test`) |
| `mcic-e2e-flakes` | Touching `test/e2e` or klusterlet timing |
| `git-commit-format` | Creating commits with DCO sign-off |
| `server-foundation` | Jira/ACM conventions |

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

Use MCP tool `get_issue` with `issue_key` set to the key from `$1` (e.g.
`ACM-12345`).

Extract from the description:

- **Required:** Context, Acceptance criteria
- **Optional:** Steps to reproduce, Expected vs actual behavior

If `--ci` is NOT set and required sections are missing, ask the user to groom
the issue before proceeding.

If `--ci` IS set, proceed with available information and note assumptions in the
PR description.

Confirm eligibility: project ACM, label `issue-for-agent`, not `agent-processed`,
status New or To Do.

### 2. Start work in Jira

After eligibility passes, transition the issue to **In Progress** (skip if already
In Progress):

- **jira-mcp-server:** `transition_issue` with `issue_key` and `transition`: `In Progress`
- **Atlassian MCP:** `getTransitionsForJiraIssue` → `transitionJiraIssue` with the
  In Progress transition id

If transition fails, comment on the issue and stop.

### 3. Codebase analysis

Search MCIC for relevant code:

- Controllers in `pkg/controller/`
- Helpers in `pkg/helpers/`, `pkg/bootstrap/`
- Tests alongside changed packages
- E2E tests in `test/e2e/` when behavior spans controllers

Use Grep and Glob. Read `test/e2e/README.md` if touching klusterlet-agent or
ManagedCluster lifecycle tests (leader-election race patterns).

### 4. Solution implementation

1. Save a plan to `.work/jira/solve/spec-<KEY>.md`
2. If `--ci` is NOT set: ask user to review the plan before coding
3. If `--ci` IS set: implement immediately
4. Follow existing patterns; add unit tests for new behavior
5. Run `make check` and `make test` — fix failures caused by your changes

### 5. Commit creation

- Branch name: `fix-<KEY>` (e.g. `fix-ACM-12345`)
- Use [Conventional Commits](https://www.conventionalcommits.org/) with a body
  explaining **why**
- Logical groupings:
  - `fix(controller):` — controller logic in `pkg/controller/`
  - `fix(helpers):` — shared helpers
  - `test:` — test additions
  - `docs:` — documentation in `docs/`

### 6. PR creation

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

### 7. Jira follow-up (optional)

After PR creation, use Jira MCP tools:

1. `add_comment` — post the PR URL on the issue
2. `update_issue` — add label `agent-processed` (if requested)

---

## Arguments

- `$1`: Jira issue key (required, e.g. `ACM-12345`)
- `$2`: Git remote to push (default: `origin`)
- `$3`: Optional `--ci` flag — skip interactive prompts
