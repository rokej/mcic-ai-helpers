# Skills index

Skills auto-load when the corresponding plugin is installed.

## jira@mcic-ai-helpers

| Skill | When it applies |
|-------|-----------------|
| `server-foundation` | ACM Jira conventions, JQL, issue grooming |

## mcic@mcic-ai-helpers

| Skill | When it applies |
|-------|-----------------|
| `mcic-build-test` | Running `make check`, `make test`, choosing E2E targets |
| `mcic-controllers` | Finding code, understanding import/detach/hosted flows |
| `mcic-e2e-flakes` | E2E tests, klusterlet leader-election timing |
| `git-commit-format` | Writing commits with DCO sign-off |

## utils@mcic-ai-helpers

| Skill | When it applies |
|-------|-----------------|
| `mcic-pr-review` | Addressing PR review comments |

## Install all plugins

```bash
/plugin marketplace add rokej/mcic-ai-helpers
/plugin install jira@mcic-ai-helpers
/plugin install mcic@mcic-ai-helpers
/plugin install utils@mcic-ai-helpers
```

Manual scripts (`run-jira-solve.sh`, `run-address-reviews.sh`) enable all three automatically.
