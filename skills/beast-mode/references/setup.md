# Bootstrap audit — set the infrastructure up, don't just document it

<!-- derived-from: none (new prose for beast-mode) · last-synced: 2026-07-04 · owner: jchris -->

beast-mode's rules depend on repo infrastructure. `/beast-mode setup` audits
it and **proposes fixes rather than merely stating preconditions** — on first
run in a repo, and as a drift check any time later. Setup runs through the
same when-to-ask lens as everything else: config-level changes are proposed
with a one-line diff and applied on approval; anything requiring scopes the
current session lacks becomes a **hand-off item** (see
[capability-routing.md](capability-routing.md)), never a silent skip.

## The checklist

For each item: check → report state → fix or hand off.

1. **Native auto-merge enabled on the repo** _(needs repo-admin to change)_ —
   the merge-on-green mechanism the loop depends on.
2. **Branch protection / required checks on the default branch** _(needs
   repo-admin)_ — ⚠️ these travel together with auto-merge: without a required
   check, an armed PR merges instantly, review finished or not. Never
   recommend enabling auto-merge without verifying a required check exists.
   Record which check is required in `config:merge`.
3. **Merge-method hygiene** _(needs repo-admin)_ — the configured
   `config:merge.method` (default rebase) enabled; squash discouraged/disabled
   per config.
4. **Labels exist with descriptions** — `config:labels.agent_created`,
   `config:labels.ready_to_merge`, and the issue type/area taxonomy from
   `config:issues`. Creating labels usually needs only triage rights; do it
   directly where possible.
5. **Reviewer-bot wiring** — the bot in `config:reviewer` is installed and its
   trigger mechanism verified, or the config explicitly marks it absent so the
   ping step skips cleanly instead of failing every PR.
6. **Capture directory** — `config:capture.dir` exists with a README
   explaining the one-file-per-note convention.
7. **Config file present and current** — `beast-mode.config.md` exists at
   **either search-order location** (repo root, or `agents/beast-mode.config.md`
   — a fallback-path config counts as present; audit it in place, never
   scaffold a duplicate at the root), parses against
   [config-schema.md](config-schema.md), and its claims match reality (the
   audit is what keeps config and reality in sync). Missing from both
   locations → scaffold one from the schema's defaults, filled with what the
   audit discovered.
8. **Discovery wiring** — the skill is listed in the repo's skills index, and
   the always-on digest is injected every session: preferably by wiring
   `hooks/session-start.sh` (which prints `assets/session-digest.md`) as a
   SessionStart hook in the repo's shared settings, with a digest in the
   always-on context file (CLAUDE.md or equivalent) as the fallback where
   hooks aren't available. An unlisted skill is invisible; an uninjected
   working style only applies when someone remembers to invoke it.

## Output

Finish with a two-part report:

- **Applied** — what was checked and fixed, one line each.
- **Hand-off queue** — remaining items as paste-ready commands with capability
  tags and verification steps, filed per the
  [runbook hand-off](capability-routing.md#the-runbook-hand-off-do-all-you-can-then-file-the-rest)
  if more than a couple.
