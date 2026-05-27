---
description: Convert this clone into a `.bare/` + worktrees layout, in place. No re-clone.
argument-hint: "[--skip-cleanup]"
---

# /git-bare-convert

Run the bundled helper script with `--yes` (Claude Code has no TTY for the script's interactive prompt; the user's invocation is the confirmation).

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/convert-to-bare.sh --yes $ARGUMENTS
```

`$ARGUMENTS` is appended verbatim. Common flag: `--skip-cleanup` (keep stale working-tree files at the project root; useful when the branch has a `/` and other top-level dirs share the prefix).

Surface the script's output to the user.

If the script exits non-zero, repeat its stderr and stop. Don't auto-stash, auto-commit, or auto-checkout — the script's pre-flight refuses unsafe states (dirty tree, detached HEAD, submodules, `.bare` already exists) on purpose.

After success, mention that more worktrees can be added with `git worktree add` or `wtree`/`wta` from the `git-worktree` plugin, and that shells/IDEs rooted at the old project root need re-pointing at `<repo>/<branch>/`.
