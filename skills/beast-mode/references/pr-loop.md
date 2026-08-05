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

## Every PR body leads with `## Why`

The first section of every PR body is `## Why` — three short sentences: the
problem or goal, why now, why this shape — above `What` and everything else.
It's the reviewer's and the human's fastest read of the change's intent. If the
repo ships a PR template it should enforce the order; when a metadata bot
regenerates the body sections, check the `Why` survived at the top and restore
it if it didn't.

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

### The reviewer is not a pre-merge gate (policy, 2026-07-12)

The configured
reviewer is async — usually a ~20–30 min COMMENT-state pass that frequently
lands AFTER merge — so waiting on it is **not** required. When your own review
says the PR is settled and it's garden-variety, merge (or arm auto-merge on
green) **without waiting for the reviewer's first pass**. The judgment to merge
is ours; the reviewer's timing does not gate it. (This reverses the older
"never arm before the reviewer's first pass" rule — deliberately, for velocity.)
Two things this does NOT relax:

- **"Settled" is a real bar, not just green CI.** You must have actually
  scrutinized the change for correctness — and for anything touching money,
  auth, data, or security, run an adversarial self-review (or a `code-review`
  subagent) before calling it settled. Green tests are necessary, not
  sufficient. Merging ahead of the reviewer means a bug it would have caught can
  land in `main` — that's the accepted trade, held in check by two backstops:
  this bar, and the late-review triage below that escalates a real miss to an
  immediate fix.
- **Risky classes still hold for a human** (the hold-for-human list below —
  schema/infra/flag-flips/etc.). That's about deploy reversibility, orthogonal
  to reviewer timing, and unchanged.

Still true once you're merging on green: **armed auto-merge survives pushes** —
if pre-merge review feedback DOES arrive while armed, disarm before pushing the
fix (else it merges on green before the re-review), then re-arm.

⚠️ Auto-merge is only safe if the default branch has **required checks**
configured — otherwise an armed PR merges instantly, review or not. The
[setup audit](setup.md) verifies this before the loop relies on it.

**Arming works _while_ required checks run — that's the whole point; arming IS
the walk-away.** With an enforced required check, a PR sits in `blocked` the
moment CI starts (the required check is pending/expected), which is exactly the
state `enable_pr_auto_merge` arms against. So: review stabilized → arm → it
merges itself on green. **Do not schedule `send_later` check-ins or watchers to
babysit the merge** — that's the anti-pattern; the merge needs nothing from you
once armed.

**If arming is refused, read the required check before reacting.** If it has
already **passed on the current head**, there's just nothing left to wait on —
that's the normal already-green case, so **merge directly**, don't escalate.
Only a refusal **while the required check is still pending** (the PR won't go
`blocked` when it should) points at a config problem — and _then_ don't build a
timer around it, **suspect the config**: branch protection / the ruleset isn't
set (the
[setup audit](setup.md) catches this at bootstrap), or an org **billing lapse
has silently stopped enforcing it mid-flight** (a runtime regression the static
audit won't catch — the reason a live arm-refusal is worth a second look). Flag
it for the human. A merge loop should never grow a watcher to compensate
for a disabled gate — that just papers over a settings regression. (This is the
lesson from a full day lost chasing an `unstable`-refusal as if it were a CI
shape problem when it was a lapsed Teams plan.)

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

## Late review: triage into a fix or a tech-nit issue

Because we merge on our own "settled" call rather than waiting for the reviewer
(above), the reviewer's pass — and the secondary reviewer's — frequently lands
**after** the PR is merged. Don't drop it, and don't reflexively revert or
reopen. Triage each late finding by one question: **would I have blocked the
merge on this if I'd seen it in time?**

- **Yes — a real regression** (correctness, security, data-integrity, money, or
  anything you'd have called P0/P1 pre-merge): open a follow-up **fix PR
  immediately**, titled "Follow-up to #\<PR\>". If the merged change also
  shipped, treat it with prod-incident urgency. This is the escape valve for
  when "settled" was wrong — and it will be sometimes; that's the cost of not
  waiting, paid down fast.
- **No — everything else** (style, naming, structure, test-shape, non-blocking
  "consider X"): file a **`tech-nit` issue** (labels `tech-nit` + the
  agent-created label), title it from the finding, link the review comment and
  the merged PR, and move on. Do **not** revert, reopen, or hotfix for a nit.

Subscription timing: the harness auto-unsubscribes the session when the PR
merges, so a late pass may not reach you live — that's fine. The reviewer's
comment persists on the PR; capture it via this triage whenever it surfaces (a
later turn, a human relay, or a quick post-merge glance at the PR's review
state). Never grow a clock timer to poll for it — that ban still holds. If a
review fix is cheap and the reviewer's pass is visibly seconds away, a _brief_
wait is fine; it is never a _gate_.

## When merge isn't deploy: surface the pending ship at wrap-up

In repos where merging the default branch does **not** deploy — prod moves only
on an explicit ship (tag / release / promotion) — a merged PR is _staged, not
live_. The failure mode: the session wraps up as "done" or "shipped" while prod
is still untouched, so finished work sits dark on the default branch for days
and each ship batch grows bigger and scarier (harder to bisect when it breaks).

So when merge ≠ deploy, the wrap-up has one extra step it must not skip:
**report what the merge staged-but-didn't-ship, and surface the ship as an
explicit decision** — never silently imply that merging shipped it.

- **State it plainly:** the merge staged the change; it is not on prod yet.
- **Report the pending-change set** — what's now on the default branch ahead of
  the live release — so the human sees the batch a ship would push.
- **Surface the ship decision:** ask for the "ship it", or hand it to whoever
  owns the deploy. Shipping stays a human call; the wrap-up only guarantees the
  ask isn't dropped.

Orthogonal to the merge loop: auto-merge on green is still how PRs merge; this
governs what you say _after_ a merge that didn't go live. Where merge _is_
deploy, skip it — the merge webhook is the ship. The only other clean skip is a
merge that changes no deployed surface (docs/notes/tooling only); say so in one
line, the same way the validation SOP allows "nothing in the diff is reachable."

## Multi-phase plans: keep moving between phases (feedback, 2026-07-10)

A plan from `writing-plans`/`executing-plans` with several phases (security
core, then wiring, then UI, ...) lands on **one branch, one PR**, same as any
other work — see "One PR per feature" above. The same default-keep-moving
posture applies phase-to-phase, not just within a phase:

> **Push the phase → once your own review says it's settled and the result
> matches the approved spec/plan → start the next phase without waiting to be
> asked** — and without waiting for the reviewer bot's pass (same
> reviewer-not-a-gate policy as merge-arming).

"Settled" means the same thing it means for the merge-arming decision: by your
own assessment the phase matches the spec/plan the human already approved, any
review feedback that has _already arrived_ is absorbed, correctness is
scrutinized (adversarial self-review for money/auth/data/security), and there's
no open blocking thread. You do **not** wait for the reviewer bot's pass to
cross a phase boundary; if its feedback lands later, triage it like any late
review (fix or `tech-nit`). Post the phase-completion status (what landed,
what's next) and then **keep going**, the same way you'd arm auto-merge the
moment CI clears rather than parking and waiting for a human click.

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

**Drop an agent seed alongside it.** In this repo, every PR that drops a blog
seed also drops **one agent seed** under `notes/agent-seeds/` (same branch, no
asking) — a proposed update to _agent memory_ (an `agents/` doc, a `CLAUDE.md`
bullet, a skill) drawn from what the PR taught the agent, as opposed to what it
taught the world. Captures, not commitments: writing one changes no memory by
itself. The two queues are **triaged together** — whenever blog seeds are
mined, agent seeds are mined too, and the triage ends by **asking the owner
which proposals to synthesize into overall memory** (the human is the gate;
nothing is applied silently). Format + process: `notes/agent-seeds/README.md`.

**Ship a Storybook story with a shared-component change.** A PR that adds or
changes a component exported from `@vibes.diy/base` (`vibes.diy/base/components/**`)
ships or updates that component's story in the same PR — the same reflex as the
capture note and the docs-page rule, and it's enforced: `pnpm lint` runs the
story-coverage gate, which fails on a new story-less component. Scaffold with
`pnpm story:new <Name>`, ratchet the seeded backlog with `pnpm story-coverage:update`,
or mark a genuinely non-visual export `// no-story: <reason>`. This is what gives
component PRs a visual reference (and the `stories/**` → auto-screenshot payoff).
Full rule: [vibes.diy's `agents/storybook-stories.md`](https://github.com/VibesDIY/vibes.diy/blob/main/agents/storybook-stories.md).

## Reviewer-bot hazards outside PRs

If `config:reviewer.issue_mention_hazard` is set: the reviewer bot treats any
@-mention in an _issue_ body (or an issue assignment) as a task and opens its
own duplicate PR. Credit it in issues without the `@` ("per Charlie's review
of #X"); assign it an issue only when you genuinely want it to implement.
@-mentions in PR comments remain the correct way to request review.
