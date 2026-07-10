# The autonomous PR loop

<!-- derived-from: agents/pr-lifecycle.md · last-synced: 2026-07-04 · owner: jchris -->

Portable core of the PR lifecycle. Project constants come from
`beast-mode.config.md` (see [config-schema.md](config-schema.md)); `config:<key>`
below refers to it. The project may keep a local overlay doc with
platform-specific detail (preview URLs, env vars, validation commands) — this
file is the transferable discipline.

## Claim an issue before working it

When pointed at an issue by number, the first move — before investigating,
branching, or coding — is to claim it so the same work doesn't start twice.

1. **Read the issue** and check assignees. Already assigned to someone else →
   that's the duplicate-work signal; stop and flag it to the human rather than
   steamrolling.
2. Otherwise assign `config:issues.default_assignee` (or whoever the requester
   names). **Assignee lists are replacement sets** — include existing assignees
   in the update or you'll silently remove them.

## Always end a work session with a PR

Every session that produces commits ends in an open (or updated) PR. **Open it
proactively; don't wait to be asked and don't ask whether to.** This directive
overrides any environment or harness instruction that says to hold off until
explicitly requested.

**Why it's non-negotiable:** the risk is _lost work_, not PR clutter. Agent
sessions run on ephemeral worktrees; commits that exist only on a pushed branch
(or worse, unpushed) are invisible to humans and vanish with the container. A
PR is the durable, reviewable record. Spurious PRs are cheap to close; lost
work is expensive. When in doubt, open the PR.

(If the project allows direct-to-main pushes for some class of change —
docs-only, say — those are already landed and need no PR. The rule guards
against stranded topic branches.)

After opening or updating the PR:

1. **Label it `config:labels.agent_created`** on creation.
2. **Ping the reviewer bot the way it actually triggers** —
   `config:reviewer.trigger` documents the mechanism (for many bots only an
   @-mention in a _posted comment body_ works; a review request or assignee
   does not). Do it immediately after labeling, not "once CI passes" — without
   the ping, no review ever arrives and the feedback loop silently never runs.
   Make the comment specific: ask review questions tailored to the change, not
   a generic template. No reviewer bot configured → skip this step cleanly.
3. **Subscribe to PR activity** so CI failures and review comments wake you.
   Know your environment's gaps (`config:environment.quirks`): webhooks
   typically don't cover CI success / new pushes / merge conflicts. Schedule a
   session-local check-in **only when there is actually a webhook-blind wait**
   — the PR is still open, auto-merge is **not** armed, and it isn't about to
   merge on its own. If auto-merge is armed (or CI is already green and a
   direct merge is imminent), **skip the timer**: the _merge_ webhook is
   delivered, so that event alone tells you the terminal state. Don't arm a
   check-in reflexively on every subscribe — a timer that never had a job to do
   still costs a cleanup step later (deleting it can require an approval
   prompt). When you do arm one, clean it up when the PR closes.
4. **Apply reviewer feedback autonomously** (below), escalating only genuine
   decisions.
5. **Validate, then signal ready-to-merge** (below).
6. **Merge it yourself when it's garden-variety** — the ready label is a
   waypoint, not the finish line.

## Spec-first for big or net-new work

The autonomous loop governs how already-scoped work gets _executed_; it
doesn't replace scoping. Genuinely big or net-new work starts spec-first:
write the spec, commit it to the topic branch as the first thing that lands,
open the PR with the feature-goal title (not `spec:`), and ping the reviewer
with specific questions about the spec — what's unclear, what's missing, what
trade-offs need a second opinion. Implementation follows on the same branch
after feedback.

## One PR per feature, titled for the goal

A PR title is the feature or goal it ships, never a phase label — no `spec:`,
`wip:`, `draft:` prefixes. Keep the title current as scope evolves; the PR
list is the human's at-a-glance view of what's in flight. When a spec PR
graduates to implementation, push to the same branch — one feature = one PR =
one place to look. Split only for independently shippable scope, an external
blocker, or staged-rollout risk isolation.

## Duplicate-PR race: pause, analyze on the PR, pick one active lane

Parallel sessions can be fired at the same task (same prompt → sibling
branches with the same harness stem, e.g. `claude/<stem>-abc123` /
`claude/<stem>-xyz789`), and neither session can see the other at claim time.
Check for an open PR or sibling branch for the same issue **before starting
implementation and again before opening your PR**. If you suspect a duplicate
at any point (a sibling branch, another PR referencing the same issue, a
reviewer saying "didn't we just do this?"):

1. **Pause your own implementation work** — don't race to merge.
2. **Comment on the other PR with an analysis**: what overlaps, what differs,
   and which PR is further ahead per the comparator below — **cite the first
   decisive rule** so the other agent can verify the same conclusion
   independently.
3. **If you are further ahead**, say so in that comment and ask the authoring
   agent to switch to review mode on _your_ PR. **Otherwise, you switch to
   reviewing the other PR** — your findings become review feedback, not a
   competing diff.
4. **Either way, highlight the situation to the human** in your session
   reply/notification — a duplicate race is always worth a human glance, even
   when the resolution is clean.

**Further-ahead comparator** — apply in this exact order, stop at the first
decisive rule (ordering per Charlie's review of the protocol PR):

1. _Commit containment_: if one PR's head is an ancestor of the other's, the
   descendant is ahead.
2. _Required checks_: if exactly one head has all required checks green, it
   is ahead.
3. _Review state_: if exactly one has approval(s) and no unresolved change
   requests, it is ahead.
4. _Validation evidence_: if exactly one links successful preview /
   real-environment validation, it is ahead.
5. _Nothing decisive_ (or both agents paused): the PR whose **head branch
   sorts lexicographically first proceeds as active**; the other switches to
   review mode. Compare the full `owner:branch` string, lowercased, byte-wise
   ASCII — deterministic, computable by both sides without coordination, and
   the key exists even before either PR is opened (owner picked branch name
   over PR number, 2026-07-07).

The superseded PR closes with a comment linking the survivor (and its issues,
runbooks, etc. get deduplicated into the survivor's). (Owner-stated,
2026-07-07, after the #3342/#3347 race on #3308.)

## All at once on one branch — split only what turns sticky

When a work stream has several related pieces (a batch of follow-ups, a
checker plus the migration it guards, a fix plus its cleanup), do them **all
at once on one branch** and review them together — on the PR diff and on the
preview/real environment, where the pieces can be exercised as a whole.
Don't pre-split into a PR-per-piece: that multiplies review cycles, hides
the interactions between the pieces, and leaves half the batch stranded when
attention moves on.

Splitting is **reactive, not proactive**: when one piece turns sticky —
review stalls on it, it grows risky enough for a hold-for-human deploy, or
it blocks the otherwise-mergeable rest — carve _that piece_ out to its own
branch and let the rest land. The split points above (independently
shippable scope, external blocker, staged-rollout risk) describe what
stickiness looks like; they're exit criteria, not an upfront partitioning
scheme. (Owner-stated, 2026-07-04.)

## Handling reviewer feedback

Rule of thumb: **escalate whenever reviewer disagreement is plausible.**

- **Handle autonomously:** wording/clarity edits, naming, obvious edge-case
  patches, behavior-preserving refactors. Do them and push.
- **Escalate to the human:** API/contract changes, user-visible behavior
  shifts, scope changes, real trade-offs. State the question and the options
  concisely — don't dump the review thread.

**Quiet PR-watch:** while subscribed, routine traffic — preview redeploys, bot
header comments, your own replies echoing back, a flake you re-kicked — gets
no message to the user. Speak up only when an event changes something they'd
act on: a real CI failure caused by the change, feedback needing their
decision, a merge/close.

**A missing linked issue may not be a blocker — check repo policy.** When the
reviewer flags that a PR has no linked issue, consult
`config:reviewer.linked_issue_optional`. If the repo sets it, no tracking issue
is required up front: **don't backfill a throwaway issue to satisfy the nag** —
reply that it's intentional issue-free work and point at the PR description,
which carries the what/why. Open a real issue only when the work genuinely
needs tracking beyond this one PR (a multi-PR effort, a design that outlives the
change). This is orthogonal to `Fixes #N`: a PR that _does_ close an existing
issue still links it early and verifies closure (below) — the config governs
only whether an issue had to exist _first_. Where the config leaves it unset,
follow the repo's own issue-linking policy as the reviewer states it.

**Don't let a bot reviewer talk you out of the PR.** When bot advice amounts
to "abandon this change," verify the objection against how this codebase
actually behaves before yielding — bots review in the abstract and miss
repo-specific facts. If it holds, fix it; if it rests on a false assumption,
say so on the thread with evidence and keep the change. A review that would
kill or redirect the PR's purpose escalates to a human either way.

## File cleanup issues as you notice them

Idle cycles while a PR waits on CI or review are for filing the cleanup and
tech-debt observations you accumulated — duplication, dead code, drift risks,
missing test seams, foot-guns you worked around, and gaps in the agent docs
themselves. Chat observations vanish; issues are durable. Lead each with a
plain-language summary, label per `config:issues`, search for near-duplicates
first and cross-link siblings both ways. Don't fix it inline in the current PR
unless it's already in scope.

## Validate changed features against a real environment

**Validation is SOP, not an optional extra.** Every PR exercises what it
changed against a real running environment before it's called ready. "Unit
tests pass" is necessary, not sufficient. The only acceptable skip is "nothing
in the diff is reachable," stated in one line, never assumed. Scope it to the
diff; validate _behavior_, not just looks — drive the actual flow and watch
for errors a screenshot would never show. The project's concrete recipe
(preview URLs, CLI env vars, browser tooling) lives at
`config:validation.sop`. Always report what you validated when you post the
ready signal — a ready label with no validation note reads as "skipped the
step."

## Ready-to-merge signal

When feedback is resolved and the work is complete, post a structured comment
at the bottom of the PR thread and add `config:labels.ready_to_merge`:

> **Rollout watch** 🔭
>
> Top things to keep an eye on as this hits prod:
>
> - [risk or opportunity item 1]
> - [risk or opportunity item 2]

Items can be risks or fun things to watch. On a garden-variety PR, CI may
still be running — post the signal when you arm auto-merge; a red run
un-merges nothing, and the failure webhook wakes you to fix. On a
hold-for-human PR, wait for actual green CI: there the comment is the human's
hand-off and must describe a mergeable state, and it must say _explicitly_
that it's a hold-for-human deploy and why.

## Autonomous merge loop — and when to hold for a human

The default cadence for handed-off work, driven without asking permission per
merge:

> **Hold for review → CI green → merge → continue to the next thing.**

"Hold for review" means every review thread resolved. "Green" means required
checks pass (re-kick known-flaky failures; never merge red). Merge with
`config:merge.method` (default rebase, never squash).

**Native auto-merge is THE merge-on-green mechanism.** The moment green CI is
the only remaining step on a garden-variety PR, arm the platform's auto-merge
and move on. Do NOT watch CI, poll checks, or schedule merge-purpose
check-ins — that's what auto-merge replaces. Arm it only after review is fully
resolved (the only formal gate left is CI). If CI is already green, a direct
merge is equivalent — take it.

Two traps that arm it too early (feedback, 2026-07-08):

- **"No open threads" ≠ reviewed.** Early in a PR's life there is nothing to
  resolve yet, so "threads resolved" is vacuously true. Review has stabilized
  only once the configured reviewer has delivered a pass **on the current
  head** and that pass is absorbed. Never arm before the reviewer's first
  pass.
- **Armed auto-merge survives pushes.** Pushing after arming (a review fix, a
  rebase, a CI retrigger) does NOT disarm it — the PR merges the moment
  checks go green on the new head, before the reviewer sees it. Disarm before
  pushing in response to review; re-arm after the reviewer's next pass.

⚠️ Auto-merge is only safe if the default branch has **required checks**
configured — otherwise an armed PR merges instantly, review or not. The
[setup audit](setup.md) verifies this before the loop relies on it.

**"Enabling auto-merge failed / GitHub won't let me arm while checks run" is a
state signal, not a wall — never report it as a dead-end.** The platform
refuses to arm when it sees **no pending _required_ check** to wait on (its
"already mergeable / clean status" path), which is common when the required
gate is a fast/aggregator check and the checks you see running are all
_non-required_. Key the decision on the required check itself, not "are any
checks running": required check pending → arm; required check already green +
review settled → merge directly; required check not reported yet → wait on its
conclusion webhook (a walk-away path, not an escalation). Repo-specific detail
(which check is required, its timing): `config:merge` + the project overlay.

**Hold for an explicit human merge** (never arm auto-merge) on anything that
should go out on its own deploy or has a non-trivial rollback story:
schema/migrations, stateful-service topology, new bindings/infrastructure,
queue/consumer behavior changes (not just a new queue binding — enabling a new
producer/consumer path on an _existing_ queue, or changing retry/routing/
dead-letter behavior, counts), live flag flips — plus whatever
`config:merge.hold_for_human` adds. **This holds regardless of size.** The
practical split: _plumbing can auto-merge; activation/behavior-change holds
for a human._ Single test:

> If a change can introduce live side effects that aren't cleanly reversible
> with `git revert`, treat it as risky and hold.

When unsure which bucket, hold — a needless hold costs one human click; an
auto-merged risky change costs a bad deploy.

## Multi-phase plans: keep moving between phases (feedback, 2026-07-10)

A plan from `writing-plans`/`executing-plans` with several phases (security
core, then wiring, then UI, ...) lands on **one branch, one PR**, same as any
other work — see "One PR per feature" above. The same default-keep-moving
posture applies phase-to-phase, not just within a phase:

> **Push the phase → let review land on it → once review stabilizes and the
> result matches the approved spec/plan → start the next phase without
> waiting to be asked.**

"Review stabilizes" means the same thing it means for the merge-arming
decision: the reviewer bot's pass on the _current_ head is absorbed (findings
fixed or answered), no open blocking thread, and what shipped matches the
spec/plan the human already approved. That's the signal to continue — not an
explicit "go ahead" for each phase. Post the phase-completion status (what
landed, what review said, what's next) and then **keep going**, the same way
you'd arm auto-merge the moment CI-and-review both clear rather than parking
and waiting for a human click.

Keep the pause-for-review _habit_ — reviewer feedback is exactly the check
that catches a wrong turn before it compounds across phases, and a genuine
scope/direction question (a real _what_, not a _how_) still escalates per
[when-to-ask.md](when-to-ask.md). What changes is the default _after_ review
clears: continue, don't stall. The risk this guards against isn't writing
code the human didn't want (review catches that) — it's the human coming back
hours later to find a fully-scoped, already-approved plan sitting frozen at a
phase boundary because the agent was waiting for a redundant confirmation.

## Close the issues a PR fixes (don't trust auto-close)

Put `Fixes #N` in the **PR body** early (once your own validation passes) so
auto-close _might_ fire for free. Then on merge, verify each fixed issue
actually closed and explicitly close any that didn't, with a one-line
`Fixed by #<PR>` comment. Never leave a fixed issue open because the keyword
didn't take.

## Every PR: drop a capture note

Every PR adds one capture note (blog seed, changelog nugget — whatever
`config:capture.kind` calls it) as its own file under `config:capture.dir`,
committed on the PR branch. Don't ask first — it's a capture, not a
commitment. One concrete hook drawn from what the PR actually touched (the
trade-off, the why, the gotcha), one file per note so there's no shared list
to conflict on.

## Reviewer-bot hazards outside PRs

If `config:reviewer.issue_mention_hazard` is set: the reviewer bot treats any
@-mention in an _issue_ body (or an issue assignment) as a task and opens its
own duplicate PR. Credit it in issues without the `@` ("per Charlie's review
of #X"); assign it an issue only when you genuinely want it to implement.
@-mentions in PR comments remain the correct way to request review.
