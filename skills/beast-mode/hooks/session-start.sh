#!/usr/bin/env bash
# beast-mode SessionStart hook: inject the always-on working-style digest into
# session context. Stdout from a SessionStart hook is added as context for the
# session. Fail open — a missing digest must never break session startup.
set -u
digest="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/assets/session-digest.md"
[ -f "$digest" ] && cat "$digest"
exit 0
