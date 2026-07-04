# beast-mode

> Follow-through for high-fan-out development. Optimized for the workflow where a human fires off many parallel, well-scoped work streams — the risk isn't the changes, it's forgetting to finish them. beast-mode is the discipline that makes every fired stream land: it always ends in a PR, absorbs review autonomously, arms the merge on green, closes the issues it fixes, hands off what the environment can't do as a runbook issue, and captures what it learned. Pick beast-mode if your failure mode is dropped threads, not bad changes.

Ten threads dispatched before lunch should be ten threads merged by dinner,
not seven merged and three orphaned on stale branches. Skills like
test-driven-development optimize the **quality of one change**; beast-mode
optimizes the **completion rate of many**.

## Install

With the [agent-skills CLI](https://github.com/vercel-labs/skills) (works for
Claude Code, Codex, Cursor, and friends — listed on [skills.sh](https://skills.sh)):

```bash
npx skills add VibesDIY/beast-mode
```

As a Claude Code plugin:

```
/plugin marketplace add VibesDIY/beast-mode
/plugin install beast-mode@beast-mode
```

Or vendor it (the right move for repos whose cloud/CI sessions don't load
global plugins): copy `skills/beast-mode/` into your repo's
`.claude/skills/beast-mode/` and commit it.

## Make it ambient (recommended)

beast-mode is designed to be **always-on, not invoked**: a SessionStart hook
injects a ~20-line digest of the loop into every session. Plugin installs get
this via `hooks/hooks.json` automatically. Vendor drops add it to
`.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/skills/beast-mode/hooks/session-start.sh\"",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Configure your repo

Run `/beast-mode setup` — it audits the repo infrastructure the loop depends
on (auto-merge, required checks, labels, capture directory) and scaffolds
`beast-mode.config.md` (reviewer handle, gate commands, label names, capture
directory, hold-for-human classes, environment quirks). Every key is optional;
missing features degrade gracefully. Contract:
[skills/beast-mode/references/config-schema.md](skills/beast-mode/references/config-schema.md).

## What's inside

- [SKILL.md](skills/beast-mode/SKILL.md) — the loop: claim → branch → PR →
  review absorbed → merged or explicit hand-off
- [references/pr-loop.md](skills/beast-mode/references/pr-loop.md) — the
  autonomous PR loop, auto-merge-on-green, hold-for-human classes
- [references/when-to-ask.md](skills/beast-mode/references/when-to-ask.md) —
  decide the *how* yourself; ask the human only about the *what*
- [references/narration.md](skills/beast-mode/references/narration.md) —
  narrate semantics, not git mechanics; issue-writing style
- [references/git-conventions.md](skills/beast-mode/references/git-conventions.md)
  — rebase not squash, never push to main, review every diff before pushing
- [references/capability-routing.md](skills/beast-mode/references/capability-routing.md)
  — desktop vs cloud detection and the hand-off queue
- [references/setup.md](skills/beast-mode/references/setup.md) — the repo
  bootstrap audit
- [references/config-schema.md](skills/beast-mode/references/config-schema.md)
  — the per-repo config contract

## Provenance

This repo is a **published mirror**. The source of truth is
[VibesDIY/vibes.diy's `.claude/skills/beast-mode/`](https://github.com/VibesDIY/vibes.diy/tree/main/.claude/skills/beast-mode),
where the skill runs ambiently in every agent session and improves through
the same reviewed daily workflow it describes — every merge there that
touches the skill auto-publishes here via
[`scripts/export-beast-mode.mjs`](https://github.com/VibesDIY/vibes.diy/blob/main/scripts/export-beast-mode.mjs)
and CI. So installs always get the latest battle-tested state, and issues/PRs
about the skill's content are best filed upstream.

Apache-2.0.
