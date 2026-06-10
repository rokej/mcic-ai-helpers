# Solve one ACM Jira issue (MCIC)

Implement a fix for a **single** groomed ACM issue and open a **draft** PR on
`stolostron/managedcluster-import-controller`.

Use when the session `instruction_prompt` contains an issue key (e.g. `ACM-12345`)
or when the user names a key explicitly.

## MCIC conventions

**Working directory:** `/workspace/managedcluster-import-controller` (`main`, module
`github.com/stolostron/managedcluster-import-controller`).

**Jira:** MCP tools only (`get_issue`, `search_issues`, `add_comment`, `update_issue`,
`transition_issue` or `transitionJiraIssue`). Host `https://redhat.atlassian.net`, project
ACM. No Jira CLI or curl.

**Verification before commit/push:** `make check` then `make test` (not `go test ./pkg/...`).
In agent-swarm pods set `GOMODCACHE=/tmp/gomodcache GOCACHE=/tmp/gocache GOPATH=/tmp/gopath`
before `make` (see `docs/agent-swarm-setup.md`).

**Branch:** `fix-ACM-<digits>`. Commits: Conventional Commits + `Signed-off-by`.

**Controller hints:** import stuck → `autoimport`, `csr`, `manifestwork`, `importconfig`;
detach → `resourcecleanup`, `clusternamespacedeletion`, `managedcluster`.

Optional disk copy: `/workspace/mcic-ai-helpers/prompts/_mcic-conventions.md` or
`docs/mcic-conventions.md` (not `docs/_mcic-conventions.md`).

## Instructions

1. **Issue key**
   - Parse from additional instructions / `instruction_prompt`
   - Format: `ACM-<digits>`
   - If missing, stop and report that a key is required

2. **Fetch issue** — MCP `get_issue` with `issue_key`
   - Extract: summary, description, labels, status
   - From description: Context, Acceptance criteria (required); repro steps if present
   - If groomed sections are thin, proceed with assumptions and document them in the PR

3. **Eligibility check**
   - Project ACM, unresolved, status New or To Do
   - Has label `issue-for-agent`, not `agent-processed`
   - If not eligible, explain why and stop (do not open a PR)

4. **Start work in Jira** — transition status to **In Progress** (MCP only):
   - If status is already **In Progress**, skip
   - **jira-mcp-server:** `transition_issue` with `issue_key` and `transition`: `In Progress`
   - **Atlassian MCP:** `getTransitionsForJiraIssue` → find transition named
     `In Progress` → `transitionJiraIssue` with that transition id
   - If transition fails, `add_comment` with the error and stop (do not open a PR)

5. **Codebase** — in `/workspace/managedcluster-import-controller`:
   - Search `pkg/controller/`, `pkg/helpers/`, `pkg/bootstrap/`, tests
   - Use controller hints above to narrow scope
   - Read `test/e2e/README.md` if touching E2E or klusterlet timing

6. **Plan** — write `/workspace/managedcluster-import-controller/.work/jira/solve/spec-<KEY>.md`
   - Problem, approach, files to change, test plan
   - In scheduled/automated runs, implement immediately (no user prompt)

7. **Implement**
   - Follow existing patterns; add unit tests for new behavior
   - Run `make check` and `make test`; fix failures from your changes

8. **Commit**
   - Branch: `fix-<KEY>` (e.g. `fix-ACM-12345`)
   - Conventional commit + `Signed-off-by`

9. **Push and draft PR**
   ```bash
   cd /workspace/managedcluster-import-controller
   git push -u origin fix-<KEY>
   gh pr create --draft --base main \
     --title "ACM-<KEY>: <short summary>" \
     --body "$(cat <<'EOF'
   ## Jira
   https://redhat.atlassian.net/browse/ACM-<KEY>

   ## Summary
   <what changed and why>

   ## Test plan
   - [x] make check
   - [x] make test

   🤖 Generated via mcic-ai-helpers agent-swarm
   EOF
   )"
   ```

10. **Jira follow-up** (MCP only)
    - `add_comment` — link the draft PR URL
    - `update_issue` — add label `agent-processed`

11. **Summary** — issue key, branch, PR URL, verification status

## Do not

- Use Jira CLI or curl
- Skip `make test` or replace with partial `go test`
- Mark PR ready for review (draft only)
- Process more than one issue in this run
