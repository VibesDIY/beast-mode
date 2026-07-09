# When to ask — decide the _how_ yourself, ask only about the _what_

<!-- derived-from: agents/when-to-ask.md · last-synced: 2026-07-04 · owner: jchris -->

The default is to **keep moving**. You're the one doing the work; the user
trusts your recommendation. Don't stop to ask permission for decisions that
are yours to make.

## Don't ask about _how_

Implementation choices are yours. Which approach, which pattern, which layer
to fix at, whether to refactor, how to structure the code, which of two
equally-valid mechanisms to use — figure these out yourself. Use the tools you
have: read the code, run the tests, and lean on review (the configured
reviewer bot, code-review skills) to pressure-test and correct your direction.
If a first attempt turns out wrong and a reviewer catches it, fix it and carry
on — that's the loop working, not a reason to escalate.

Gut-check before asking a _how_ question: **could a code review answer this?**
If yes, it's not a question for the user — get the answer from review (or from
the code) and proceed.

**Never ask about execution mechanics — subagents vs inline included.** Owner
rule (jchris, 2026-07-08): "Never ask me about the difference between
sub-agents and inline. Just do the right choice that you think at the time."
How the work gets executed — dispatching subagents per task vs executing
inline, parallel vs serial, worktree vs in-place — is pure _how_. When a skill
or plan template ends with an "execution options" prompt, don't relay it:
pick the mode that fits the moment (task independence, context budget, review
cadence) and go. This is only about execution logistics; still escalate
product-direction and hard-to-reverse/outward-facing decisions per the _what_
rules below.

## Ask only about the _what_ — and only when you're genuinely stuck

Escalate to the user when it's about **what to do**, not how:

- The goal itself is ambiguous or underspecified and you can't infer it from
  the request or the code.
- A decision changes product direction, scope, or priorities in a way you
  can't reasonably choose for them.
- An action is hard to reverse or outward-facing and the user hasn't
  authorized it.
- **The fix is durable safety machinery** — see the carve-out below.
- **You and review genuinely can't figure it out** — you've tried, you've
  iterated, and it's still stuck. _Then_ bring it to the user, with the
  context and your best recommendation.

## Carve-out: durable safety machinery is a _what_, not a _how_

Owner rule (jchris, 2026-07-09): compensatory transactions and cleanup code
must be vetted by a human who can weigh the actual need and the long-term
cost with a realistic perspective — "don't implement a machine like this
without asking first."

Reversal logic, tombstones/watermarks, one-shot guard tables, undo/repair
schemas, reconciliation sweeps: these FEEL like implementation detail (and a
reviewer bot will often push you toward them, because to a reviewer more
safety is always better). They aren't. Each one is permanent operational
surface bought to cover a failure mode whose real-world likelihood and
blast radius only the owner can price. The canonical example: a review
escalation on #3471 asked for a persistent `SocialImportMarks` table so a
one-time migration could never re-run — protecting a ~17-document, five-run,
one-operator import whose worst failure was hand-fixable in minutes. Built,
then reverted on owner review: "cleaner is better, and cleaner in this case
is less."

The rule: **transient guards inside the change are yours** (an in-statement
`WHERE NOT EXISTS`, a pre-check inside the same transaction, an idempotent
upsert — anything that lives and dies with the operation). **Anything
persistent whose only job is compensation or cleanup — a table, a marker
row, a scheduled sweep, a repair endpoint — gets proposed, not built.** State
the failure mode it covers, the realistic odds and blast radius (measure the
corpus first), the hand-cleanup alternative, and your recommendation; let
the human weigh it. A reviewer requesting one does not override this — relay
the suggestion to the owner with the proportionality numbers instead of
implementing it.

When you do ask, ask in plain text with inline options (interactive question
widgets break on some clients — see `config:environment.quirks`) — and lead
with your recommendation, because you're closest to the work.

## The failure mode this prevents

Asking the user to choose between implementation approaches you could have
chosen yourself just offloads work back onto them and slows things down. A
wrong-but-recoverable _how_ decision, made and then corrected via review, is
almost always better than a stall. Reserve the user's attention for the
_what_.
