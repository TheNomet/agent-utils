---
description: Create a new git worktree (branch folder) in the bare-clone layout and continue working inside it.
argument-hint: "<branch> [base]"
---

# /worktree-add

Spin up a new git worktree using the bundled `wta` helper, then continue the user's task from inside the new folder.

`$ARGUMENTS` is forwarded verbatim to `wta`. Run `wta -h` for the full list of forms. The one form worth flagging here, because it's easy to miss: `wta <branch> .` (or `--here`) forks from the **current** worktree's HEAD instead of `origin/HEAD` — needed when you're already on a feature branch and the user wants a sub-worktree off it.

## Choosing the base

Run `pwd` and `git rev-parse --abbrev-ref HEAD` first.

- On the default branch or at the bare root → default `wta <branch>` is right (forks from `origin/HEAD`).
- On a non-default branch and the user implies branching from where you are ("a worktree off this", "a sub-experiment") → `wta <branch> .`.
- User named a base explicitly → pass it as the second arg.

When in doubt, ask.

## Steps

1. **Verify the layout.** Confirm the current working directory (or any ancestor) contains a `.bare/` directory and a one-line `.git` file pointing at it. If not, refuse and tell the user this command only works inside a bare-clone worktree layout — point them at `wtree <repo-url>` to bootstrap one.

2. **Run wta and `cd` into the result, in one step.** A plain script can't change the parent shell's directory; you must capture the path on stdout and `cd` to it explicitly. Use this exact bash form:

   ```bash
   NEW_WORKTREE=$("${CLAUDE_PLUGIN_ROOT}/scripts/wta" $ARGUMENTS | tail -n1) \
     && cd "$NEW_WORKTREE" \
     && pwd
   ```

   Why `tail -n1`: `wta` writes progress messages to **stderr** (which streams to the user) and the new worktree path to **stdout** as the final line. `tail -n1` plucks the path; the rest of stderr passes through visibly. The capture form is also what the user types interactively (`cd "$(wta foo)"`), so the agent and human paths stay symmetric.

3. **Confirm the cd.** Run `pwd` (or trust the previous chained `&& pwd`) and verify the path looks like the new worktree. All subsequent shell commands for this task should run from this directory.

4. **Report back.** One or two lines: the branch, the folder path (relative to the project root), and the base it was forked from (or "checked out existing branch" if `wta` detected an existing remote branch). Read the captured stderr from `wta` to know which case applied — it logs one of:
   - `checking out existing local branch '<branch>' into <path>`
   - `checking out existing remote branch 'origin/<branch>' into <path>`
   - `creating new branch '<branch>' off '<base>' in <path>`

5. **Continue the task** the user actually asked about, now from inside the new worktree.

## Notes

- Don't run `git worktree add` directly — go through `wta` so behavior stays consistent with the user's manual workflow.
- If `wta` reports the branch already exists on origin, it checks it out instead of creating it. That's expected; mention it in the report so the user knows you didn't accidentally create a duplicate.
- If the user wants to remove a worktree afterwards, point them at `wtr <path>` (or `wtr <path> --delete-branch` to also drop the branch if merged).
