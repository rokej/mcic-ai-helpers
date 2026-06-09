# Agent-swarm prompts

Model-agnostic workflow prompts for [agent-swarm](https://github.com/rokej/agent-swarm)
(OpenCode/Crush). Sync this folder as a **Prompt Source** in a Swarmer workspace.

These mirror HyperShift [AI-assisted CI jobs](https://hypershift.pages.dev/how-to/ci/ai-assisted-ci-jobs/)
but target `stolostron/managedcluster-import-controller` and run on agent-swarm
instead of Prow.

## Prompt map

| File | HyperShift equivalent | Agent-swarm session | Schedule (example) |
|------|----------------------|---------------------|-------------------|
| `jira-agent-pipeline.md` | `periodic-jira-agent` | `mcic-jira-agent` | `30 8 * * 1` (Mon 08:30 UTC) |
| `jira-agent-queue.md` | JQL query step only | `mcic-jira-queue` | Manual / on-demand |
| `jira-solve.md` | `/jira:solve` for one key | `mcic-jira-solve` | On-demand + `instruction_prompt: ACM-12345` |
| `address-reviews-batch.md` | `periodic-review-agent` | `mcic-review-agent` | `0 8-23/3 * * 1-5` |
| `address-reviews.md` | `address-review-comments` | `mcic-address-reviews` | On-demand + `instruction_prompt: PR 42` |

## Shared reference

Read `_mcic-conventions.md` at the start of every workflow (paths, verification,
Jira rules, commit format).

## Workspace layout

Configure session repos so the agent pod has:

| Clone path | Repository |
|------------|------------|
| `/workspace/managedcluster-import-controller` | `stolostron/managedcluster-import-controller` |
| `/workspace/mcic-ai-helpers` (optional) | `rokej/mcic-ai-helpers` — for `check_replied.py` |

Working directory for `make` / `gh`: `/workspace/managedcluster-import-controller`

## MCP

Enable workspace **Jira MCP** (`jira-mcp-server` / atlassian-jira catalog entry).
Use MCP tools only — no Jira CLI or curl.

## Claude Code parity

`plugins/` slash commands and skills are for local Claude Code. Agent-swarm uses
these `prompts/` files instead.

Setup guide: [docs/agent-swarm-setup.md](../docs/agent-swarm-setup.md)
