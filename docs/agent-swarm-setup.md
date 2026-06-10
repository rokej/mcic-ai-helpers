# Agent-swarm setup for MCIC

Wire [mcic-ai-helpers](https://github.com/rokej/mcic-ai-helpers) prompts into
[agent-swarm](https://github.com/rokej/agent-swarm) for scheduled Jira solve and
PR review loops (phase 3 — not Prow).

## Architecture

```
Prompt Source (git)     Session (cron)          Agent pod
─────────────────────   ─────────────────       ─────────────────────────────
rokej/mcic-ai-helpers   mcic-jira-agent         OpenCode/Crush + gh + make
  prompts/*.md          cron: 30 8 * * 1        /workspace/managedcluster-import-controller
                        mode: prompt            Jira MCP (jira-mcp-server)
```

| Session | Prompt file | Role |
|---------|-------------|------|
| `mcic-jira-agent` | `prompts/jira-agent-pipeline.md` | Query queue → solve one issue → draft PR |
| `mcic-jira-queue` | `prompts/jira-agent-queue.md` | List queue only (debug) |
| `mcic-jira-solve` | `prompts/jira-solve.md` | On-demand: `instruction_prompt: ACM-12345` |
| `mcic-review-agent` | `prompts/address-reviews-batch.md` | Batch agent PR reviews |
| `mcic-address-reviews` | `prompts/address-reviews.md` | On-demand: `instruction_prompt: 42` |

## 1. Workspace

Create a Swarmer workspace (UI or API) with:

### Repositories

| Repo | Clone path | Branch |
|------|------------|--------|
| `stolostron/managedcluster-import-controller` | `/workspace/managedcluster-import-controller` | `main` |
| `rokej/mcic-ai-helpers` | `/workspace/mcic-ai-helpers` | `main` |

The helpers repo provides `check_replied.py`, conventions on disk (`prompts/_mcic-conventions.md`,
`docs/mcic-conventions.md`), and the git prompt source. Workflow prompts embed conventions inline
so a single injected prompt is self-contained — refresh the prompt source after updates.

### GitHub credentials

- PAT or GitHub App with `contents`, `pull_requests`, `issues` on MCIC
- `gh` uses `GITHUB_TOKEN` or configured auth in the agent environment

### Go build cache (required for `make check` / `make test`)

Agent pods use a default `GOPATH` under `/home/node/go` that is often **not
writable**. You need **both**:

1. **agent-swarm** (recent): session pods inject `GOMODCACHE`, `GOCACHE`, `GOPATH`
   under `/tmp` — redeploy agent-swarm and start a **new session** after upgrading.
2. **mcic-ai-helpers**: clone `rokej/mcic-ai-helpers` to `/workspace/mcic-ai-helpers`
   so agents can run:
   ```bash
   source /workspace/mcic-ai-helpers/scripts/lib/go-env.sh
   cd /workspace/managedcluster-import-controller
   make check
   ```
   Or: `./scripts/verify-mcic.sh all` from the helpers repo.

Optional override via workspace **Environment Variables** (same three keys under
`/tmp`) — only needed on older agent-swarm builds without pod defaults.

`make check` can take several minutes (remote lint script + `go list`). Allow
timeouts ≥ 5 minutes for verification steps.

### Jira MCP

Catalog entry: **atlassian-jira** / `jira-mcp-server`

Environment variables:

| Variable | Example |
|----------|---------|
| `JIRA_SERVER_URL` | `https://redhat.atlassian.net` |
| `JIRA_EMAIL` | `you@redhat.com` |
| `JIRA_ACCESS_TOKEN` | API token |

Use MCP tools only — no Jira CLI in agent pods.

## 2. Prompt source

Add a **Prompt Source** pointing at this repository:

| Field | Value |
|-------|-------|
| Repository | `rokej/mcic-ai-helpers` (or your fork) |
| Branch | `main` |
| Path | `prompts` |
| Sync | On schedule or manual refresh after prompt changes |

Prompt index: [prompts/README.md](../prompts/README.md)

## 3. Sessions

### Periodic Jira agent

| Field | Value |
|-------|-------|
| Name | `mcic-jira-agent` |
| Mode | `prompt` |
| Prompt | `jira-agent-pipeline.md` |
| `cron_schedule` | `30 8 * * 1` (Monday 08:30 UTC) |
| Working dir | `/workspace/managedcluster-import-controller` |

Non-interactive: pipeline processes **one** groomed issue per run.

### Periodic review agent

| Field | Value |
|-------|-------|
| Name | `mcic-review-agent` |
| Mode | `prompt` |
| Prompt | `address-reviews-batch.md` |
| `cron_schedule` | `0 8-23/3 * * 1-5` (every 3h weekdays, 08:00–23:00 UTC) |

### On-demand sessions

| Session | `instruction_prompt` example |
|---------|------------------------------|
| `mcic-jira-solve` | `ACM-33390` |
| `mcic-address-reviews` | `PR 42` |

## 4. Jira grooming

Before the periodic agent can pick work:

1. ACM issue in New or To Do, unresolved
2. Label `issue-for-agent`
3. Description with Context + Acceptance criteria

See [jira-issue-grooming.md](jira-issue-grooming.md).

After successful solve, the agent adds `agent-processed`.

## 5. Verification checklist

After first session run:

- [ ] Jira MCP: `search_issues` returns groomed queue
- [ ] `gh auth status` succeeds in pod
- [ ] `make check` and `make test` run in MCIC clone
- [ ] Draft PR created with title `ACM-XXXXX: ...`
- [ ] Jira comment with PR link + `agent-processed` label

## 6. Local parity

| Agent-swarm prompt | Claude Code equivalent |
|--------------------|------------------------|
| `jira-agent-pipeline.md` | `list-jira-queue.sh` + `run-jira-solve.sh` |
| `jira-solve.md` | `/jira:solve` |
| `address-reviews.md` | `/utils:address-reviews` |
| `address-reviews-batch.md` | (no script yet — run address-reviews per PR) |

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Empty queue | JQL in `_mcic-conventions.md`; labels on issue |
| MCP auth failure | `JIRA_*` env vars in workspace MCP config |
| `make test` fails in pod | envtest/kubebuilder assets; network for sdk-go scripts |
| PR not created | `gh` token scopes; branch push permissions |
| Duplicate review replies | Clone `mcic-ai-helpers`; `check_replied.py` path |
| `permission denied` on `go/pkg/mod/cache` | `source .../go-env.sh` or upgrade agent-swarm + new session (see above) |
| `make check` hangs / times out | Normal on first run; increase tool timeout; check network for lint curl |
