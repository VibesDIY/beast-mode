# Git conventions

<!-- derived-from: agents/git-workflow.md + agents/coding-standards.md (review-commits) · last-synced: 2026-07-04 · owner: jchris -->

Portable git discipline for agent-driven work. The merge method itself comes
from `config:merge.method`; everything here is about how branches are made,
named, and kept trustworthy on the way to that merge.

## Always check the current branch before acting

Never assume the current branch is the same as before — other agents and the
human may have switched branches between turns. Run
`git branch --show-current && git status -s` at the start of any task that
touches git (commits, pushes, tags, rebases) or edits files. Stale branch
assumptions ship the wrong code. Treat branch awareness like a shell prompt:
always know where you are before acting.

## Rebase, never squash

Merge and update with rebase (`config:merge.method`, default `rebase`) —
never squash, never merge-commit, and don't reopen the question per-PR: it's
a settled convention, not a per-change debate. Rebase preserves every
individual commit and its committer through the whole chain, which is what
makes collaborative long-running branches auditable.

## Rebase topic branches onto integration branches

Always rebase topic branches onto their integration branch — never merge the
integration branch into a topic branch. Merging creates noise in PR diffs
(extra merge commits, unrelated files showing up).

```bash
git fetch origin
git rebase origin/<integration-branch>   # before pushing or creating a PR
```

## Topic branches are namespaced by the originating human

Topic branches are named `<github-account>/<topic>` after the human who
originated the work — agents working on someone's behalf use that person's
account prefix (default: `config:issues.default_assignee`). The prefix tells
everyone at a glance who's driving the branch and prevents collisions when
multiple humans + agents push topic branches concurrently.

Worktree tools that auto-generate names like `worktree-<topic>` or
`issue-<n>-<topic>` produce orphan-looking branches in the PR list — rename
before the first push, or branch under the correct name from the start.
Branches that already shipped under a different name stay as-is; the rule
applies to new branches.

## No amend / no force-push on shared branches

On any branch that other people or other agents pull from, **always create
new commits** — never `git commit --amend`, never `git push --force-with-lease`.
Rewriting history that others may have pulled is never safe; new commits on
top always are. Topic branches that are clearly your own can be amended
freely until they're pushed for review.

## Review every commit before pushing

Read the full diff of every commit before `git push`, checking each pattern
against the project's code standards. If something looks like a workaround,
it probably is — rethink the approach or raise it rather than shipping a
"cries for help" pattern. Reviewers will catch it anyway; catching it
yourself keeps the review loop tight.
