<beast-mode>
This repo runs beast-mode: follow-through for high-fan-out development. Every
work stream ends merged or as an explicit hand-off — never a dangling branch,
never a silent stall. The always-on rules:

- Read `agents/beast-mode.config.md` (or root `beast-mode.config.md`) for this
  repo's reviewer bot, labels, gate commands, and environment quirks.
- Pointed at an issue → claim it first. Decide the _how_ yourself; ask the
  user only about the _what_.
- Every session that produces commits ends in an open PR — proactively, no
  asking. Label it, ping the reviewer per config, subscribe, absorb feedback
  autonomously, validate the diff against a real environment.
- The reviewer is NOT a pre-merge gate (policy, 2026-07-12): it's async, so on
  your own "settled" call + garden-variety → arm native auto-merge (rebase) or
  merge on green, WITHOUT waiting for its first pass. "Settled" is a real bar
  (adversarial self-review or a `code-review` subagent for money/auth/data/
  security; green CI is necessary, not sufficient). If pre-merge review DOES
  arrive while armed, disarm before pushing the fix (armed auto-merge survives
  pushes), then re-arm. Only arm where a verified required check gates the
  default branch; otherwise merge directly on green. Risky classes (schema,
  infra, flag flips, non-clean revert) still hold for a human. Late review
  (lands after merge) → triage: real regression = immediate follow-up fix PR;
  else a `tech-nit` issue — never revert/reopen for a nit. Verify fixed issues
  actually closed. Drop the capture note.
- Work this environment can't do (scopes/secrets/admin) → finish everything it
  CAN do, then file one runbook issue for the privileged agent.
- Orchestrate, don't operate: the top level plans, decides, and talks to the
  user; search/scan/grep (incl. pasted UI literals) runs on `scout`
  (haiku/low), execution on `implementer` (opus/medium) — both in
  `.claude/agents/` — and multi-stage fan-out goes through the Workflow tool,
  a standing opt-in: never ask per task. The top-level context is long-lived:
  conclusions come up, dumps stay down in subagents. Messages to the user say
  _what_, never narrate _how_; questions reach the user only for product
  one-way doors — technical calls you genuinely can't crack yourself go to
  the reviewer as PR comments, prior art is a search requirement (sweep
  before inventing — never a reviewer ping), and two-way doors get the best
  available call, noted on the PR. Lots of workable uncertainty → build it
  anyway and open the PR as a DRAFT (it can't merge; burn the questions down
  there), rather than bringing the pile to the user. Non-trivial user
  messages route through the persistent `comms` gate agent (spawn once,
  continue via SendMessage), which returns SEND (relay verbatim) or SILENCE.
  Standing async channel: post conclusions to the private
  `jchris/backchannel` vibe and drain its queued `message` docs at session
  start and wrap-ups; whenever you say "backchannel" to the user, link
  <https://vibes.diy/vibe/jchris/backchannel>. Parsimony is a core value. Full flow:
  `agents/session-flow.md`.
- Narrate the work, not the workstation. Speak on decisions, surprises,
  failures that change the outcome or need the user (self-recovered errors
  are silent choreography too), and the wrap-up — NEVER on a successful tool
  result. "Typecheck
  passes", "all tests green", "pushed", "PR labeled", "tool loaded", "let me
  run X" are silent choreography; if a sentence just restates a green check
  the user could see in the tool log, delete it and batch the gauntlet into
  one wrap-up line. This rule decays over long sessions — re-read it when you
  notice yourself announcing a passing gate.

Depth on demand: `.claude/skills/beast-mode/SKILL.md` and its references
(pr-loop, when-to-ask, session-flow, narration, capability-routing, setup,
config-schema).
</beast-mode>
