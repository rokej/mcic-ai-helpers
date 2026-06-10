# Address review comments on one MCIC PR

Address review feedback on a single pull request in
`stolostron/managedcluster-import-controller`.

Use when `instruction_prompt` contains a PR number (e.g. `42` or `PR 42`).

## MCIC conventions

**Working directory:** `/workspace/managedcluster-import-controller`. **Verify after
changes:** `make check`, `make test`. **Push:** `git push --force-with-lease` after
amending commits. **Reply footer:**

```
---
*AI-assisted response via agent-swarm*
```

**Duplicate check:** `/workspace/mcic-ai-helpers/plugins/utils/scripts/check_replied.py`

**Go caches in agent-swarm pods** — always before `make`:

```bash
source /workspace/mcic-ai-helpers/scripts/lib/go-env.sh
```

Or run `/workspace/mcic-ai-helpers/scripts/verify-mcic.sh check` (or `test` / `all`).
If `permission denied` on `/home/node/go/pkg/mod`, `go-env.sh` was not sourced.

## Instructions

1. **PR number**
   - Parse from additional instructions / `instruction_prompt`
   - If missing: infer from current branch via `gh pr list --head "$(git branch --show-current)"`
   - If still unknown, stop and ask for a PR number (on-demand sessions only)

2. **Checkout**
   ```bash
   cd /workspace/managedcluster-import-controller
   gh pr checkout <PR>
   git pull
   ```
   - Working tree must be clean before edits

3. **Fetch context**
   ```bash
   gh pr view <PR> --json title,body,baseRefName,headRefName,author
   gh api repos/stolostron/managedcluster-import-controller/pulls/<PR>/comments
   gh api repos/stolostron/managedcluster-import-controller/issues/<PR>/comments
   ```
   - Skip bot noise and already-resolved threads where possible
   - Prioritize: ACTION_INSTRUCTION → BLOCKING → CHANGE_REQUEST → QUESTION → SUGGESTION

4. **Duplicate replies**
   - Before posting, check if you already replied (search thread for automation footer)
   - If `/workspace/mcic-ai-helpers` exists:
     ```bash
     python3 /workspace/mcic-ai-helpers/plugins/utils/scripts/check_replied.py \
       stolostron managedcluster-import-controller <PR> <comment_id> --type <inline|issue>
     ```
     Exit 0 = safe to reply; exit 1 = skip

5. **Address feedback**
   - Code changes only when reviewer uses imperative language ("fix", "change", "remove")
   - Questions: reply with explanation only — no drive-by refactors
   - One response per feedback: inline **or** general comment, not both
   - Default: **amend** the relevant commit in the PR (not new commits per comment)

6. **Rebase if requested**
   ```bash
   BASE=$(gh pr view <PR> --json baseRefName -q '.baseRefName')
   git fetch origin && git rebase origin/"$BASE"
   ```
   - Resolve conflicts; re-run verification

7. **Verify** — only when you changed code (skip for reply-only questions with no edits):
   ```bash
   source /workspace/mcic-ai-helpers/scripts/lib/go-env.sh
   cd /workspace/managedcluster-import-controller
   make check   # allow several minutes; remote lint + go list
   make test
   ```
   - Do not push if failures are caused by your changes
   - Do not skip verification because of cache errors — fix env vars first
   - Do not claim tests passed if verification did not complete

8. **Push once** — skip if no code changes
   ```bash
   git push --force-with-lease
   ```

9. **Post replies** — after push when code changed; for reply-only, post without push.

   **Inline review comment** (reply in thread):
   ```bash
   gh api repos/stolostron/managedcluster-import-controller/pulls/<PR>/comments \
     -X POST -f body="$(cat <<'EOF'
   <your reply>

   ---
   *AI-assisted response via agent-swarm*
   EOF
   )" -F in_reply_to=<comment_id>
   ```

   Do **not** use `gh pr review --comment` for inline threads — it posts a top-level
   review, not a thread reply.

10. **Summary** — PR link, comments addressed vs skipped, verification status

## Do not

- Push without `make check` and `make test` when code changed
- Skip verification and post replies when `make` failed or timed out (except pure
  explanation replies with zero code changes)
- Run only `go test` on changed packages instead of `make test`
- Reply twice to the same comment thread
