---
description: Fetch and address PR review comments on managedcluster-import-controller
argument-hint: "[PR number] [--preview]"
---

## Name
utils:address-reviews

## Synopsis
```
/utils:address-reviews [PR number] [--preview]
```

## Description

Automate addressing PR review comments on
`stolostron/managedcluster-import-controller`. Fetches comments via `gh`,
categorizes by priority, implements valid changes, and posts replies.

**Usage:**

```
/utils:address-reviews 42 --preview
/utils:address-reviews
```

Default repo: `stolostron/managedcluster-import-controller`.

### Applicable skills

| Skill | Use when |
|-------|----------|
| `mcic-build-test` | Pre-push verification |
| `mcic-pr-review` | Reply format, amend strategy |
| `git-commit-format` | Commit messages + Signed-off-by |
| `mcic-controllers` | Understanding change context |

## Implementation

Follow the standard address-reviews flow. Key MCIC-specific overrides:

### Verification (Step 3.5)

Detect and run in order:

1. `make check` — copyright + lint
2. `make test` — full unit test suite

```bash
make check
make test
```

Do NOT run only `go test ./changed/package/`. Do NOT skip `make test` if
`make check` has unrelated failures — diagnose each separately.

E2E is not required for review fixes unless the reviewer explicitly asks.

### Commit strategy

- Default: amend the relevant commit in the PR
- Use conventional commits with a body explaining why
- Push once at the end with `git push --force-with-lease`

### Reply signature

All replies must end with:

```
---
*AI-assisted response via Claude Code*
```

### Duplicate prevention

Before posting any reply:

```bash
CHECK_REPLIED="${CLAUDE_PLUGIN_ROOT}/scripts/check_replied.py"
python3 "$CHECK_REPLIED" stolostron managedcluster-import-controller <PR> <comment_id> --type <type>
```

Exit 0 = safe to reply. Exit 1 = already replied. Exit 2 = error, do not reply.

---

## Step 0: Checkout PR branch

1. Determine PR number from `$ARGUMENTS` or `gh pr list --head <branch>`
2. `gh pr checkout <PR_NUMBER>` then `git pull`
3. Verify clean working tree

## Step 1–5

Follow the full address-reviews workflow:

1. Fetch PR context with selective filtering (skip bots, large comments)
2. Categorize: ACTION_INSTRUCTION → BLOCKING → CHANGE_REQUEST → QUESTION → SUGGESTION
3. Address comments (use `--preview` to confirm each action when flag is set)
4. Run `make check` and `make test` before push
5. Post replies, then `git push --force-with-lease`, then summary

## Response rules

1. One response per feedback — inline OR general comment, never both
2. Code changes only when explicitly requested (imperative language)
3. Questions get explanations only, no code changes

## Arguments

- `$1`: PR number (optional — uses current branch if omitted)
- `--preview`: Confirm each comment's proposed action before executing
