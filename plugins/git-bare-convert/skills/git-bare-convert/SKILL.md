---
name: git-bare-convert
description: Convert an existing plain `git clone` into a `.bare/` + per-branch-worktree layout, in place, without re-cloning. Triggers on "convert this clone to a bare repo", "transform this into a bare folder", "switch to worktrees", "make .git a pointer to .bare", "bare-ify this repo". Does NOT cover the no-clone-yet case — point at the `git-worktree` plugin's `wtree` helper for that.
---

# git-bare-convert

Run the `/git-bare-convert` slash command. It calls the bundled script, which does pre-flight, the conversion, and verification in one Bash invocation.

```
/git-bare-convert
```

Pass `--skip-cleanup` if the current branch contains `/` and other top-level dirs share the prefix (the script's plan output lists collisions — re-run with the flag to keep them).

## What the script does

`${CLAUDE_PLUGIN_ROOT}/scripts/convert-to-bare.sh --yes` is what the command runs. It moves `.git/` → `.bare/`, writes a `.git` pointer file (`gitdir: ./.bare`), re-attaches the current branch as a sibling worktree, and removes the now-stale working-tree files at the project root.

It refuses (exit 2) if any of these is true:

- not in a git repo, or `.git` is already a file (already converted, or this is itself a worktree)
- `.bare/` already exists
- `.gitmodules` present (submodule re-init isn't handled)
- working tree dirty (don't auto-stash; ask the user to commit or stash)
- HEAD detached (ask the user to check out a named branch)

Surface the script's stderr verbatim on any non-zero exit. Do not try to "fix" the precondition.

## After it succeeds

The repo now has `.bare/`, `.git` (pointer), and `<branch>/`. Tell the user:

- More worktrees: `git worktree add <path> <branch>`, or `wtree`/`wta` from the `git-worktree` plugin.
- Shells/IDEs rooted at the old project root need re-pointing at `<repo>/<branch>/`.
