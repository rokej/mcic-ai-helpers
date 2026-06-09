---
name: mcic-pr-review
description: PR review response conventions for managedcluster-import-controller. Use when addressing review comments via utils:address-reviews.
---

# MCIC PR review responses

## Verification before push

After code changes, run:

```bash
make check
make test
```

See `mcic-build-test` skill for details. Do not push if failures are caused by your changes.

## Commit strategy

- **Default: amend** the relevant commit in the PR
- Follow `git-commit-format` skill (conventional commits + Signed-off-by)
- Single push at end: `git push --force-with-lease`

## Reply format

Keep replies short:

```
Done. <one line what changed>. <optional why>

---
*AI-assisted response via Claude Code*
```

## Duplicate check

Before replying, run `check_replied.py`:

```bash
python3 plugins/utils/scripts/check_replied.py stolostron managedcluster-import-controller <PR> <id> --type <type>
```

## Response rules

1. One response per feedback — inline OR general comment, never both
2. Code changes only when reviewer uses imperative language ("fix", "change", "remove")
3. Questions get explanations only — no drive-by refactors

## Rebase requests

```bash
BASE_BRANCH=$(gh pr view <PR> --json baseRefName -q '.baseRefName')
git fetch origin && git rebase origin/"$BASE_BRANCH"
```

Resolve conflicts, re-run `make check` and `make test`, then push.

## Repo context

- Target: `stolostron/managedcluster-import-controller`
- OWNERS in repo root `OWNERS` — prioritize feedback from approvers/reviewers listed there
