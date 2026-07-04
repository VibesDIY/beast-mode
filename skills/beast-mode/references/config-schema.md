# `beast-mode.config.md` — the per-repo config contract

<!-- derived-from: none (new prose for beast-mode) · last-synced: 2026-07-04 · owner: jchris -->

One small markdown file parameterizes everything project-specific in
beast-mode. Search order: `beast-mode.config.md` at the repo root, then
`agents/beast-mode.config.md` — **the first file found wins; a fallback-path
config is fully "present"** (setup audits it in place and never scaffolds a
duplicate at the root).

**Graceful degradation is the contract:** every key is optional. A missing key
means "use the default below"; an explicitly-absent feature (the sentinel
`none`) means "skip the dependent steps cleanly". No config file at all → run
with pure defaults and suggest `/beast-mode setup`.

## Value shapes

So a second repo doesn't have to infer formatting: one `## <key>` section per
top-level key; each subkey is a bullet ``- `subkey`: value``. Scalars
(commands, handles, labels) are inline code. Lists are either a comma list in
one bullet or nested bullets — both read the same. Pointers to project docs
are normal markdown links. Explicit absence is the literal word `none` as the
value. Prose after a value is commentary for the agent, not part of the value.

## Keys and defaults

### `reviewer`

- `handle` — the review bot's @-handle. Default: none → skip the ping steps
  cleanly (and the "hold for review" gate reduces to human review, if any).
- `trigger` — what actually summons it (e.g. "@-mention in a posted PR
  comment body; review requests and assignees do NOT trigger it").
- `issue_mention_hazard` — `true` if @-mentioning the bot in an _issue_
  body/assignment makes it open its own duplicate PR (then: never live-mention
  it in issues). Default: `false`.

### `labels`

- `agent_created` — label applied to every agent-opened PR/issue. Default:
  `agent-created` (create it via setup if absent).
- `ready_to_merge` — the ready-state label. Default: `ready-to-merge`.

### `gate`

- `fast` — the pre-commit check command. Default: none → run the project's
  standard lint/build if one is discoverable, else rely on CI.
- `full` — the heavyweight suite and when it's worth running. Default: none →
  CI is the full gate; don't invent a local one.

### `issues`

- `default_assignee` — who claims issues by default. Default: none → don't
  self-assign or reassign; state in the issue/PR who should triage.
- `type_labels` / `area_labels` — the labeling taxonomy for filed issues.
  Default: apply `labels.agent_created` only.

### `merge`

- `method` — merge method for the loop. Default: `rebase` (never squash).
- `required_check` — the check that gates auto-merge. Default: **unknown → do
  NOT arm auto-merge** until the setup audit has verified a required check
  exists on the default branch; merge directly on green instead.
- `hold_for_human` — project-specific additions to the risky classes that
  always hold for a human merge (baseline: schema/migrations, stateful-service
  topology, new bindings/infra, queue/consumer behavior — not just new queue
  bindings but enabling a new producer/consumer path on an existing queue or
  changing retry/routing/dead-letter behavior — live flag flips, any
  non-clean-revert).

### `validation`

- `sop` — pointer to the project doc with the concrete validation recipe
  (preview URLs, CLI env vars, browser tooling). Default: none → still
  validate (the SOP obligation doesn't degrade away): exercise the diff
  against whatever real environment is reachable and report exactly what you
  did — only the recipe is project-specific, not the requirement.

### `capture`

- `dir` — capture-note directory. Default: none (skip the capture step).
- `kind` — what a note is called (blog seed, changelog nugget, …).

### `environment`

- `quirks` — a list of known per-environment-class limits, each with the
  capability it removes and the workaround. This is the file that stops
  agents from re-discovering the same limitation every session.

### `voice`

- Optional TTS ping conventions (desktop-only). Default: none.

## Minimal worked example

The smallest useful config for a fresh repo — everything else defaults:

```markdown
# beast-mode.config.md — acme/widgets

## reviewer

- `handle`: none

## gate

- `fast`: `npm run lint && npm run build`

## issues

- `default_assignee`: `alice`

## merge

- `required_check`: `test` (verified by /beast-mode setup on 2026-07-04)

## capture

- `dir`: `docs/dev-notes/`
- `kind`: dev note
```

For a fully-populated example, see vibes.diy's live config:
[`agents/beast-mode.config.md`](https://github.com/VibesDIY/vibes.diy/blob/main/agents/beast-mode.config.md).
