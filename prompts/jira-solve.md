# Solve one ACM Jira issue (MCIC)

Implement a fix for a **single** groomed ACM issue and open a **draft** PR on
`stolostron/managedcluster-import-controller`.

Use when the session `instruction_prompt` contains an issue key (e.g. `ACM-12345`)
or when the user names a key explicitly.

## Instructions

1. Read `_mcic-conventions.md` (paths, Jira MCP, verification, commits).

2. **Issue key**
   - Parse from additional instructions / `instruction_prompt`
   - Format: `ACM-<digits>`
   - If missing, stop and report that a key is required

3. **Fetch issue** — MCP `get_issue` with `issue_key`
   - Extract: summary, description, labels, status
   - From description: Context, Acceptance criteria (required); repro steps if present
   - If groomed sections are thin, proceed with assumptions and document them in the PR

4. **Eligibility check**
   - Project ACM, unresolved, status New or To Do
   - Has label `issue-for-agent`, not `agent-processed`
   - If not eligible, explain why and stop (do not open a PR)

5. **Codebase** — in `/workspace/managedcluster-import-controller`:
   - Search `pkg/controller/`, `pkg/helpers/`, `pkg/bootstrap/`, tests
   - Use controller map in conventions to narrow scope
   - Read `test/e2e/README.md` if touching E2E or klusterlet timing

6. **Plan** — write `/workspace/managedcluster-import-controller/.work/jira/solve/spec-<KEY>.md`
   - Problem, approach, files to change, test plan
   - In scheduled/automated runs, implement immediately (no user prompt)

7. **Implement**
   - Follow existing patterns; add unit tests for new behavior
   - Run `make check` and `make test`; fix failures from your changes

8. **Commit**
   - Branch: `fix-<KEY>` (e.g. `fix-ACM-12345`)
   - Conventional commit + `Signed-off-by` (see conventions)

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
