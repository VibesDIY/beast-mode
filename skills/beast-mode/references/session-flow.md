# Default session flow — orchestrate, don't operate

<!-- derived-from: agents/session-flow.md · last-synced: 2026-07-11 · owner: jchris -->

Portable core of the session shape. Project constants come from
`beast-mode.config.md` (see [config-schema.md](config-schema.md)); `config:<key>`
below refers to it, with the agent roster and the async channel under
`config:session-flow`. The project may keep a thin overlay doc with the
repo-specific agent files and channel wiring — this file is the transferable
discipline.

The top-level session is a long-lived **orchestrator**: it plans, decides,
delegates, and talks to the user. Everything that dumps content into context —
searching, reading at volume, implementing, reviewing — runs in subagents. The
user manages the product, not the process. **Parsimony is a core value**:
fewest agents, fewest files, fewest messages that get the job done.

## Model tiers

The agent roster is `config:session-flow.agents`: a small set of repo-defined
subagents, each pinning its own `model`/`effort` in frontmatter so dispatch
needs no per-call overrides. The standing shape is three tiers:

| Work                                                       | Tier                                                                                |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Orchestration, planning, synthesis, judgment, final review | top-level session (heavy read-for-planning → a plan/explore agent at the top model) |
| Execution: implement, test, commit; spec + quality reviews | an `implementer` tier (execution model)                                             |
| Search, scan, grep, locate — especially pasted UI literals | a `scout` tier (cheap/fast model)                                                   |

Subagents may spawn subagents (an implementer can dispatch its own scout);
depth is capped by the harness, and only conclusions flow upward.

## Orchestrate via the Workflow tool

Multi-stage or fan-out work runs through the **Workflow tool** (deterministic
`pipeline()`/`parallel()` scripts), not hand-rolled chains of Agent calls.
Where `config:session-flow.workflow_opt_in` is `standing`, this is a standing
opt-in — never ask per task whether to use multi-agent orchestration. In
scripts, `agent(prompt, {agentType: '<tier>'})` reuses the repo agents (their
frontmatter model/effort applies); the plain Agent tool remains for one-off
dispatches. Parsimony applies to scripts too: `pipeline()` by default, a
barrier only when a stage genuinely needs all prior results, no stages that
exist for tidiness.

## Context hygiene — the top level reads conclusions, not sources

- If a step's output is a file dump, log, wide diff, or search sweep, it
  belongs in a subagent. The top level keeps only decisions and short reports.
- Construct dispatch prompts with exactly the context the subagent needs (full
  task text inline — never "go read the plan").
- Subagents return compact structured reports (`file:line`, verdict, status —
  contracts are in each agent file). Never let a subagent's report paste file
  contents back up.

## Communication contract — say what, ask why, never how

Messages to the user are only what they need to hear:

- **Say what**: outcomes, decisions made, product-visible effects, deliverable
  links. One wrap-up beats ten updates.
- **Never how**: no mechanics, tool logs, or process narration — the full rule
  is [narration.md](narration.md).
- **Self-recovered failures are silence too**: an error you caught and fixed
  (a bad dispatch, a crashed tool, a retry) is process, not product — recover
  and keep going. Speak about a failure only when it changes the outcome or
  timeline, or needs a user decision.
- **Hook and system feedback is workstation noise**: a hook prompt, stop-hook
  nag, or harness reminder is not a user question — act on it (or correctly
  decline to) silently. Never send the user a message whose only content is
  explaining workstation state.
- **Ask why, rarely**: questions reach the user only for **product one-way
  doors** — irreversible or hard-to-reverse product decisions. Two-way doors
  (reversible calls): pick the best option, note the call on the PR, keep
  moving. Ask in plain text with inline options (interactive question widgets
  break on some clients — see `config:environment.quirks`).
- **Workable uncertainty → draft PR, not a question**: when a task has a lot
  you're unsure about but can work through, don't bring the pile to the user
  — build it and open the PR as a **draft**. A draft can't merge, so nothing
  is at risk while the open questions burn down on the PR (with the reviewer);
  flip it to ready once they're resolved. Asking remains the fallback only
  for a genuine product one-way door buried in the pile.
- **Technical uncertainty never goes to the user**: resolve it yourself first
  — read the code, run the tests, check the docs ([when-to-ask.md](when-to-ask.md)).
  Only a call you genuinely can't crack becomes a PR comment framed as a
  review gate for the reviewer. Ordinary uncertainty is not a gate; the
  durable-safety-machinery carve-out (propose, never build unasked) still
  applies.
- **Prior art is a search requirement, not a review gate**: before inventing
  anything, run the sweep yourself (a scout/explore agent — "match existing
  conventions; search wider before inventing one"). Don't ping the reviewer for
  prior-art lookups — ordinary review surfaces the reuse it spots, and the
  when-to-ask threshold (escalate to review only what code + search can't
  resolve) stays as-is.
- Between decision points, silence is the default.
- **Calibration**: the silence rules govern messages, not the transcript —
  tool-call descriptions and brief orienting lines stay readable when the user
  reads the command list. Tune the terseness level to the user
  (`config:session-flow.terseness`); don't reflexively compress further.

## The comms gate — a fresh-context peer that vets user messages

Before sending any non-trivial user message, pass a raw brief to a persistent
`comms` gate agent (see `config:session-flow.agents`); it returns `SEND`
(relay verbatim) or `SILENCE` (send nothing). It is **persistent**: spawn it
once per session, continue the same agent via SendMessage — its context
carries only the contract plus past briefs/verdicts (so the contract doesn't
decay) and it knows what the user already heard (so nothing repeats). It is a
**strategic peer**, not a copyeditor: it may attach a `NOTE TO DISPATCHER`
(drift, open threads, a question that's really a two-way door) — weigh those
as peer counsel; the note is guidance for you, never relayed to the user.
Short direct answers to direct questions skip the gate.

## The async channel — messages both ways, no open window required

A private owner-only board (`config:session-flow.async_channel`) is the
standing async queue between sessions and the user: they read conclusions and
queue instructions from any device, no live window required.

- **Post conclusions down**: subagent conclusions and wrap-ups worth reading
  later go in as `update` docs (shape + write command in
  `config:session-flow.async_channel`). Mirror comms-gate `SEND` messages
  there when they'd matter after the session ends.
- **Drain the queue up**: at session start and at every wrap-up, query for
  queued `message` docs — each is a real user instruction: act on it, then
  mark it read. Concrete doc shapes, the `db put`/`query` commands, and any
  access-control note live with the channel entry in config.

## Superpowers run without asking

The vendored workflow skills (brainstorming → writing-plans →
subagent-driven-development, TDD, reviews, worktrees) are the default way to
work — invoke them and dispatch their subagents autonomously; never ask
permission for a skill or a dispatch. Two-stage reviews per
subagent-driven-development run on the execution tier. Parallel implementer
dispatch follows the project's parallel-dispatch rules.
