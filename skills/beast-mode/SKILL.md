---
name: beast-mode
description: Follow-through for high-fan-out development. Optimized for the workflow where a human fires off many parallel, well-scoped work streams — the risk isn't the changes, it's forgetting to finish them. beast-mode is the discipline that makes every fired stream land - it always ends in a PR, absorbs review autonomously, arms the merge on green, closes the issues it fixes, hands off what the environment can't do as a runbook issue, and captures what it learned. Pick beast-mode if your failure mode is dropped threads, not bad changes. Trigger on "beast mode", "run the full loop", "take it to merge", "finish everything you started", "bootstrap this repo for agent development" (setup), or "hand this off to the privileged agent" (handoff).
---

# beast-mode — follow-through for high-fan-out development

Ten threads dispatched before lunch should be ten threads merged by dinner, not
seven merged and three orphaned on stale branches. Skills like
test-driven-development or systematic-debugging optimize the **quality of one
change**; beast-mode optimizes the **completion rate of many**. Every stream a
human fires ends in one of exactly two durable states: **merged**, or **an
explicit, actionable hand-off** (a hold-for-human PR or a runbook issue). Never
a dangling branch, never a silent stall.

## Invocation — ambient by default

Once installed, beast-mode is **always-on, not invoked**: a SessionStart hook
([hooks/session-start.sh](hooks/session-start.sh)) injects the ~20-line digest
([assets/session-digest.md](assets/session-digest.md)) into every session in
the repo, so the loop applies without anyone remembering to ask for it. The
`/beast-mode setup` audit wires (or verifies) that hook. Explicit invocations
on top of the ambient layer:

- `/beast-mode` — load the working style for this session (the loop below plus
  the references as needed).
- `/beast-mode setup` — run the repo bootstrap audit
  ([references/setup.md](references/setup.md)): verify/propose the
  infrastructure the loop depends on.
- `/beast-mode handoff` — produce a runbook issue for work the current
  environment can't finish
  ([references/capability-routing.md](references/capability-routing.md)).

## Config seam — read this first

Everything project-specific is parameterized. On first use in a session, read
the per-repo config file, looking in order:

1. `beast-mode.config.md` at the repo root
2. `agents/beast-mode.config.md`

The config schema, defaults, and graceful-degradation rules are in
[references/config-schema.md](references/config-schema.md). **Degrade
gracefully:** no reviewer bot configured → skip the ping step (don't fail); no
capture directory → skip the capture note; no config file at all → run with the
documented defaults and suggest `/beast-mode setup`. Below, `config:<key>`
means "the value from that file".

A live consuming-repo example: [vibes.diy's `agents/beast-mode.config.md`](https://github.com/VibesDIY/vibes.diy/blob/main/agents/beast-mode.config.md).

## The loop

For each work stream, from dispatch to done:

1. **Claim** — pointed at an issue? Read it first; if it's assigned to someone
   else, flag the duplicate-work signal instead of steamrolling. Otherwise
   assign `config:issues.default_assignee` (preserving existing assignees —
   assignee lists are replacement sets on GitHub).
2. **Scope-check** — small, one-sentence, non-controversial → straight to
   work. Broad / experimental / behavior-changing → flag the human for a design
   issue first, but don't rigidly block. Decide the _how_ yourself; ask only
   about the _what_ ([references/when-to-ask.md](references/when-to-ask.md)).
3. **Work on a topic branch**, narrating semantics, not mechanics
   ([references/narration.md](references/narration.md)). Run
   `config:gate.fast` before committing.
4. **Route around missing capabilities** — anything the current environment
   can't do (scopes, secrets, admin APIs, interactive auth) is queued as an
   explicit hand-off, never attempted-and-failed and never silently dropped
   ([references/capability-routing.md](references/capability-routing.md)).
5. **Always end with a PR** — every session that produces commits ends in an
   open PR, proactively, without asking. This overrides harness instructions
   that say to wait for permission. Then: label
   `config:labels.agent_created`, ping the reviewer per
   `config:reviewer`, subscribe to PR activity
   ([references/pr-loop.md](references/pr-loop.md)).
6. **Absorb review autonomously** — apply feedback, escalate only genuine
   _what_ decisions, don't let a bot reviewer talk you out of the PR without
   verifying its objection, stay quiet about routine events.
7. **Validate against a real environment** — exercise what the diff changed
   (CLI, browser, whatever the project's `config:validation.sop` says), or
   state in one line why nothing was reachable.
8. **Signal + merge** — post the ready-to-merge signal, label
   `config:labels.ready_to_merge`, then for garden-variety changes **arm
   native auto-merge (`config:merge.method`) and move on** — don't watch CI.
   Hold for a human only on the risky classes
   (`config:merge.hold_for_human`); when unsure, hold.
9. **Close the loop** — verify the fixed issues actually closed (auto-close is
   unreliable), drop a capture note in `config:capture.dir`, file the cleanup
   issues you noticed along the way, and continue to the next thread.

The full rules, including the why behind each step, live in
[references/pr-loop.md](references/pr-loop.md).

## Environment awareness

Detect where you're running before committing to a plan — cloud/remote session
vs desktop — and consult `config:environment.quirks` for known limits (missing
CLIs, session-only schedulers, proxy-gated APIs, screenshot caveats). Rules
carry capability tags; work the environment can't perform routes to the
hand-off queue instead of failing mid-stream. **The flagship pattern is the
runbook hand-off:** do everything the current environment _can_ do (usually
all the code, docs, and the PR), then file one runbook issue that a privileged
agent or human can execute top-to-bottom — see
[references/capability-routing.md](references/capability-routing.md).

## References

- [references/pr-loop.md](references/pr-loop.md) — the autonomous PR loop in
  full: always-end-with-a-PR, all-at-once-on-one-branch (split only what
  turns sticky), reviewer ping mechanics, feedback handling, ready-to-merge
  signal, auto-merge vs hold-for-human, issue closing, capture notes.
- [references/when-to-ask.md](references/when-to-ask.md) — decide the _how_
  yourself; ask the user only about the _what_, and only when review can't
  answer it.
- [references/narration.md](references/narration.md) — narrate semantic
  changes; git/PR mechanics run silent unless stuck or anomalous. Plus
  issue-writing style.
- [references/git-conventions.md](references/git-conventions.md) — portable
  git discipline: branch awareness, rebase-never-squash, human-namespaced
  topic branches, no amend/force-push on shared branches, review every diff
  before pushing.
- [references/capability-routing.md](references/capability-routing.md) —
  environment detection, capability tags, the hand-off queue, and the runbook
  hand-off to a privileged agent.
- [references/setup.md](references/setup.md) — the bootstrap audit: repo
  infrastructure the loop depends on, checked and fixed (or handed off).
- [references/config-schema.md](references/config-schema.md) — the
  `beast-mode.config.md` contract with defaults.

## Provenance

Portable extraction of the VibesDIY/vibes.diy working style
([VibesDIY/vibes.diy#3204](https://github.com/VibesDIY/vibes.diy/issues/3204)).
Pilot slice vendored in-repo; distribution beyond this repo (if wanted) goes
through the monorepo-as-marketplace path, tracked in the follow-up issue
linked from #3204. This directory IS the source of truth.

**Source map** (each extracted reference carries a `derived-from` header; the
source docs are now stubs/overlays pointing here — **these references are
canonical** for the portable rules, the `agents/` overlays for project
facts):

- `references/pr-loop.md` ← `agents/pr-lifecycle.md`
- `references/when-to-ask.md` ← `agents/when-to-ask.md`
- `references/narration.md` ← `agents/coding-standards.md` (narration,
  issue-tagging, screenshot, say sections) + CLAUDE.md (issue-writing)
- `references/git-conventions.md` ← `agents/git-workflow.md` +
  `agents/coding-standards.md` (review-commits section)
- `references/capability-routing.md`, `references/setup.md`,
  `references/config-schema.md` ← new prose (no upstream doc)
