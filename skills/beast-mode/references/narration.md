# Narration & writing style

<!-- derived-from: agents/coding-standards.md (narration, issue-tagging, screenshots, say) + CLAUDE.md (issue-writing) · last-synced: 2026-07-04 · owner: jchris -->

## Narrate semantics, not mechanics

Progress narration — the text the user reads while an agent works — describes
the **semantic change being made**: what behavior or code is changing and why.
Not git/repo mechanics. Commits, pushes, branch restarts, rebase syncs,
force-with-lease recoveries, PR creation, labeling, review-request plumbing,
and check-in scheduling are routine choreography: do them silently.

Say "making the reconnect loop pause while the tab is hidden", not "committing
and pushing to the branch" / "opening the PR and labeling it".

The exceptions, where mechanics ARE the story:

- **Stuck or blocked** — a push rejected for a reason you can't resolve, a
  rebase conflict needing a real decision, CI infrastructure misbehaving.
- **Anomalies** — anything that surprised you or changed the plan (a branch
  someone else force-moved, a merge that didn't auto-close its issue, a deploy
  that didn't pick up the change).
- **Deliverables** — the final PR/issue link and the outcome belong in the
  wrap-up; it's the play-by-play that doesn't.

## Issue-writing style

- **Lead with a one/two-sentence plain-language summary** of the problem,
  before any technical detail, file paths, or repro steps. A teammate triaging
  the backlog should know what an issue is without decoding it.
- **Label on creation** — a type label plus at least one area label, plus the
  agent-created label when an agent files it (taxonomy from
  `config:issues`). Untagged issues are manual triage debt.
- **File it the moment you notice it** — cleanup, tech debt, and doc gaps go
  to issues when spotted, not chat mentions that evaporate. Idle
  waiting-on-CI windows are the canonical time.
- Every link clickable: full markdown links, never bare `owner/repo#123`
  shorthand.

## Wrap-up discipline

- Visual/styling work streams end with a **screenshot of the changed screen in
  its new state** attached to the closing message — the diff is not the look.
  Honor the project's screenshot caveats (`config:environment.quirks`, e.g.
  headless-browser dark-mode force-darkening producing misleading captures).
- Voice/TTS pings (where configured, desktop-only): only after a waiting
  period completes or an epic finishes — never to announce the start of work.
  Ultra-terse; see `config:voice`.
