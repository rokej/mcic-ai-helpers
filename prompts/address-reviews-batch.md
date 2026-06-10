# Batch address reviews on MCIC agent PRs

Periodic **review-agent** flow: find open draft PRs from the Jira solve agent,
rebase if needed, address reviews, fix CI-related feedback where possible.

> **Conventions are inline below.** Do not read `_mcic-conventions.md` from `/workspace/`.

## MCIC conventions

**Working directory:** `/workspace/managedcluster-import-controller`. **Verify:**
`make check`, `make test`. Follow `address-reviews.md` steps per PR. **Helpers repo:**
`/workspace/mcic-ai-helpers` for `check_replied.py`.

## Instructions

1. **Find candidate PRs**
   ```bash
   cd /workspace/managedcluster-import-controller
   gh pr list --repo stolostron/managedcluster-import-controller \
     --state open --draft \
     --json number,title,headRefName,author,createdAt \
     --limit 30
   ```
   Filter to agent-created PRs:
   - Head branch matches `fix-ACM-*`, **or**
   - PR body contains `mcic-ai-helpers` or `agent-swarm`, **or**
   - Author matches bot account from workspace config (if configured in `instruction_prompt`)

   Sort by `createdAt` ascending. Cap at **3 PRs per run** unless `instruction_prompt` sets another limit.

2. **Empty set**
   - If no candidates: report success, nothing to do

3. **Per PR** — run the `address-reviews.md` workflow:
   - Checkout → fetch comments → address → `make check` + `make test` → push → reply

4. **Rebase stale PRs** (before addressing comments if branch is behind base):
   ```bash
   gh pr checkout <PR>
   BASE=$(gh pr view <PR> --json baseRefName -q '.baseRefName')
   git fetch origin && git rebase origin/"$BASE"
   git push --force-with-lease
   ```

5. **CI failures**
   - If PR has failing checks, read logs via `gh pr checks <PR>` and `gh run view`
   - Fix only if failure is clearly caused by PR changes (not infra flakes)
   - Comment on PR if blocked by external flake

6. **Limits**
   - Do not merge PRs
   - Do not mark draft PRs ready for review
   - Stop after processing the cap; list remaining PRs in summary

7. **Final summary** — table: PR #, branch, actions taken, verification, open threads left

## Optional instruction_prompt overrides

| Prompt text | Effect |
|-------------|--------|
| `limit 5` | Process up to 5 PRs |
| `author <login>` | Filter PR author |
| `PR 42` | Process only PR 42 (delegates to single-PR flow) |

## Do not

- Process non-agent PRs unless they match filters above
- Merge or close PRs without explicit human instruction
