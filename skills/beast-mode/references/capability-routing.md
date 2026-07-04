# Capability routing — environment awareness and the hand-off queue

<!-- derived-from: none (new prose for beast-mode; quirk examples from agents/pr-lifecycle.md + CLAUDE.md) · last-synced: 2026-07-04 · owner: jchris -->

beast-mode exists to kill dropped threads. The subtlest way to drop a thread
is to run it in an environment that can't finish it: the agent burns turns
rediscovering a limit, fails mid-stream, or silently skips the step. Routing
is the fix — know what the current environment can't do, do everything it
_can_ do, and turn the remainder into an explicit hand-off artifact.

## Detect the environment class

At session start (cheap probes, no ceremony):

- **Cloud/remote session** — ephemeral container, repo cloned fresh, egress
  usually proxied, no interactive browser login, often no local CLIs (`gh`,
  `say`), schedulers session-only.
- **Desktop** — full local auth (`gh`, signing keys, browsers, TTS), durable
  but attended.
- **Privileged agent** — a session (either class) holding elevated scopes:
  repo-admin, org settings, cross-repo access, deploy secrets, production
  credentials.

Then consult `config:environment.quirks` for the project's known specifics
(which tools are absent where, screenshot caveats, proxy behavior). Don't
re-derive documented quirks experimentally.

## Capability tags

Each rule or workflow step carries what it needs, e.g.:

- `repo-admin` — branch protection, auto-merge settings, labels at org level
- `cross-repo` — creating or writing repos outside the session's scope
- `local-gh-auth` — anything needing the authenticated `gh` CLI
- `interactive-login` — flows requiring a human-attended browser auth
- `secrets` — deploy tokens, production credentials
- `tts` / `desktop-ui` — voice pings, real-browser screenshots
- `durable-scheduler` — check-ins that must survive the session

Before starting a step, match its tags against the current environment. A
mismatch routes the step to the hand-off queue — it does not block the rest of
the stream.

## The hand-off queue

Work the environment can't perform is **queued as an explicit hand-off, never
attempted-and-failed and never silently dropped** — dropped threads are
exactly the failure mode this skill exists to kill. A hand-off item states:

1. What needs doing and why (one plain sentence).
2. The exact commands/API calls, ready to paste, with expected output.
3. Which capability was missing (`needs repo-admin`, `needs desktop`).
4. How to verify it worked.

Small queues (one or two items) ride in the PR description or wrap-up message.
Anything bigger becomes a runbook issue:

## The runbook hand-off (do-all-you-can, then file the rest)

**The pattern:** when a task spans capabilities the current environment lacks,
split it at the capability boundary — not at the task boundary.

1. **Do everything the current environment CAN do, first.** Usually that's
   all of the code, docs, config, tests, and the PR itself. Don't stop at the
   first privileged step and hand off the whole task; the privileged agent's
   time is the scarce resource, so arrive with the maximum done.
2. **Then file ONE runbook issue** for the remainder, written so the
   privileged agent (or human) can execute it top-to-bottom without
   re-deriving context:
   - Lead with the plain-language goal and a link to the PR/branch carrying
     the finished portion — state clearly what is ALREADY done, so the
     privileged agent doesn't redo it.
   - **Anchor it against staleness:** record the PR URL, branch, head SHA,
     base SHA, and a generated-at timestamp. The runbook's first execution
     step is to verify the branch head still matches the recorded SHA — if it
     moved (rebase, new commits), re-read the diff and update the runbook
     before executing, rather than running steps written against a stale
     tree.
   - Then the remaining steps as an **ordered runbook**: exact commands, API
     calls, file contents where needed, expected outputs, and a verification
     step per item. Tag each step with the capability it needs, and note
     per step whether it's **idempotent** (safe to re-run blind) or needs a
     check-before-apply / rollback note — privileged re-runs must not create
     duplicate side effects (double labels are harmless; a second repo-setting
     PATCH or a re-sent notification may not be).
   - Include the "definition of done" — what to check, which issues to close,
     what to report back.
   - Label per `config:issues` (agent-created + type + area), assign per
     `config:issues.default_assignee`, and cross-link the PR and the runbook
     issue both ways.
3. **The runbook issue is the durable hand-off artifact** — same reasoning as
   always-end-with-a-PR. A hand-off that lives only in chat evaporates; an
   issue survives the session and shows up in triage.

The reverse routing also applies: cloud-preferred work (long PR babysitting,
webhook subscriptions, preview validation loops) gets suggested INTO cloud
sessions when the user is on desktop.

## Anti-patterns

- Attempting a privileged call "to see if it works", failing, and burning
  turns on retries the environment can never satisfy.
- Stopping the whole stream at the first missing capability instead of
  finishing everything unprivileged first.
- Writing the hand-off as prose ("someone should enable branch protection")
  instead of paste-ready commands with verification.
- Splitting the remainder into several vague issues instead of one executable
  runbook.
