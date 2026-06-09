# MCIC periodic Jira agent pipeline

Full **periodic-jira-agent** flow: query groomed queue → pick **one** issue →
solve → draft PR → Jira updates.

Designed for **non-interactive** scheduled runs (`instruction_prompt` empty or `--ci`).

## MCIC conventions

**Working directory:** `/workspace/managedcluster-import-controller`. **Jira:** MCP only
(`search_issues`, `get_issue`, `add_comment`, `update_issue`). **Verify:** `make check`,
`make test`. **Agent queue JQL:**

```
project = ACM AND resolution = Unresolved AND status in (New, "To Do") AND labels = issue-for-agent AND labels != agent-processed ORDER BY created ASC
```

## Instructions

1. **Query queue** — MCP `search_issues`:
   - `jql`: agent queue JQL above
   - `max_results`: `1`

2. **Empty queue**
   - If no issues: report "agent queue empty" and stop successfully
   - Do not open PRs or modify Jira

3. **Pick issue**
   - Use the single returned issue (oldest by `created`)
   - Record `issue_key` and summary in your working notes

4. **Solve** — follow the same steps as `jira-solve.md` for that `issue_key`:
   - `get_issue` → analyze → plan file → implement → `make check` + `make test`
   - Branch `fix-<KEY>`, conventional commits, draft PR
   - Jira: `add_comment` (PR link) + `update_issue` (label `agent-processed`)

5. **Limits**
   - Process **exactly one** issue per run (`MAX_ISSUES = 1`)
   - Do not start a second issue even if time remains

6. **Failure handling**
   - If implementation or tests fail after reasonable fixes: do **not** add `agent-processed`
   - `add_comment` on the issue with failure summary and any branch name (no PR if none created)
   - Report failure in final summary for operators

7. **Final summary**
   - Issue key, outcome (PR URL or failure reason), `make check` / `make test` status

## Do not

- Ask the user for confirmation (automated mode)
- Use Jira CLI or curl
- Process multiple issues per run
