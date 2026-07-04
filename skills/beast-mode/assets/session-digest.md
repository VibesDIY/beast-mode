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
- Green + resolved + garden-variety → arm native auto-merge (rebase) and move
  on — only where a verified required check gates the default branch;
  otherwise merge directly on green. Risky classes (schema, infra, flag
  flips, non-clean revert) hold for a human. Verify fixed issues actually closed. Drop the capture note.
- Work this environment can't do (scopes/secrets/admin) → finish everything it
  CAN do, then file one runbook issue for the privileged agent.
- Narrate semantics, not git mechanics.

Depth on demand: `.claude/skills/beast-mode/SKILL.md` and its references
(pr-loop, when-to-ask, narration, capability-routing, setup, config-schema).
</beast-mode>
