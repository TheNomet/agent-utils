---
description: Symlink (or copy) the bundled wtree/wta/wtl/wtr scripts onto $PATH so the user can drive the bare-clone + worktree workflow from any shell.
argument-hint: "[--copy] [--dir <path>]"
---

# /wtree-install

Install every helper this plugin ships so the user can drive the bare-clone + worktree workflow from any shell, without needing the agent-utils repo cloned locally.

## What gets installed

Four scripts, symlinked (default) into `$HOME/.local/bin`:

- `wtree` — bootstrap a new bare-clone layout: `wtree <repo-url>` inside an empty directory.
- `wta` — add a worktree: `wta <branch> [base]`. Branch defaults the folder name to the same as the branch; base defaults to `origin/HEAD`. Prints the new worktree path on the last line of stdout so users can do `cd "$(wta <branch>)"`.
- `wtl` — list worktrees with branch + last-commit subject.
- `wtr` — remove a worktree, optionally with `--delete-branch` to drop the branch if merged.

The shared library `wt-common.sh` is **not** installed alongside — the scripts walk symlinks back to their real location and source it from the plugin dir directly. This keeps the install dir uncluttered.

## Arguments

`$ARGUMENTS` may include:

- `--copy` — copy the scripts instead of symlinking. Survives `/plugin uninstall` but won't track plugin updates.
- `--dir <path>` — install into a directory other than `$HOME/.local/bin`.

## Steps

1. **Sanity-check the source.** `${CLAUDE_PLUGIN_ROOT}/scripts/` must contain `wtree`, `wta`, `wtl`, `wtr`, and `wt-common.sh`. The four binaries should be `+x`. If anything is missing, abort.

2. **Resolve the install dir.** Default `$HOME/.local/bin`; override with `--dir <path>` (expand `~`). `mkdir -p` it.

3. **Check `$PATH`.** If the install dir isn't on the user's `$PATH`, defer the warning to the end and remember the exact `export PATH="<dir>:$PATH"` line the user would need to add to their rc.

4. **For each of `wtree`, `wta`, `wtl`, `wtr`** (NOT `wt-common.sh` — see above):
   - Inspect any existing file at `<install-dir>/<name>`. If it's already a symlink to `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`, mark "already installed". If it's anything else (a different file, an older copy, a stale symlink), show what's there and ask before overwriting. Don't clobber silently.
   - Default install: `ln -sf "${CLAUDE_PLUGIN_ROOT}/scripts/<name>" "<install-dir>/<name>"`.
   - With `--copy`: `cp` then `chmod +x`. Note in the success message that copies don't auto-update.

5. **Verify.** Run `command -v wtree wta wtl wtr` and confirm each resolves to the install dir. Run `wta --help 2>&1 | head -1` (or any of them) to confirm the scripts execute and can find their library through the symlink walk.

6. **Print a tight success message.** Include:
   - Install path and mode (symlink/copy).
   - Each helper that was installed, skipped, or already present.
   - The PATH-warning line from step 3 if applicable.
   - One usage example:
     ```bash
     mkdir my-repo && cd my-repo
     wtree git@github.com:org/my-repo.git
     cd "$(wta feat/EDM-1234)"   # add a worktree and cd into it
     ```

## Notes

- This command does not edit the user's shell rc. There is no auto-cd shell function — the helpers are plain scripts, and a script can't change its parent shell's directory. If the user wants `wta` to also `cd`, they wrap it themselves: `cd "$(wta <branch>)"`.
- To reverse this, run `/wtree-uninstall`. It removes the symlinks (or copies, if they still match the plugin's version).
- If `${CLAUDE_PLUGIN_ROOT}` is unset, abort: the plugin isn't loaded properly. Tell the user to install via `/plugin install git-worktree@agent-utils` first.
- Never run `wtree`, `wta`, etc. as part of this command — installation is separate from any actual repo bootstrap.
