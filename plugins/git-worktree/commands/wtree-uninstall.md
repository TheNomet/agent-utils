---
description: Remove the wtree/wta/wtl/wtr scripts (and the wt-common.sh library) installed by /wtree-install.
argument-hint: "[--dir <path>] [--dry-run]"
---

# /wtree-uninstall

Reverse `/wtree-install`: remove the helper symlinks (or copies) from the install directory.

Safe by design: only removes files this plugin actually installed. Foreign files at the same paths are left alone with a warning.

## Arguments

`$ARGUMENTS` may include:

- `--dir <path>` — install directory to clean (default: `$HOME/.local/bin`). Must match whatever the user passed to `/wtree-install`.
- `--dry-run` — print what would be removed without doing it. Useful when you're not sure which install dir the user used.

## Steps

1. **Resolve the install dir** the same way `/wtree-install` does: `--dir <path>` if given, else `$HOME/.local/bin`. Don't `mkdir`; if it doesn't exist, there's nothing to do.

2. **For each of `wtree`, `wta`, `wtl`, `wtr`:**
   - Inspect `<install-dir>/<name>`. Skip silently if it doesn't exist.
   - **If it's a symlink:** read the target with `readlink`. Compare against `${CLAUDE_PLUGIN_ROOT}/scripts/<name>`.
     - Match → remove with `rm`. Report removed.
     - Mismatch → leave it. Report "left foreign symlink at `<path>` (points at `<target>`)" so the user knows.
   - **If it's a regular file:** compare its content against `${CLAUDE_PLUGIN_ROOT}/scripts/<name>` byte-for-byte (`cmp -s`). This catches the `/wtree-install --copy` case.
     - Identical → remove. Report removed.
     - Different → leave it. Report "left modified file at `<path>` — content differs from the plugin version, presumed intentional".
   - **If it's anything else** (directory, special file) — leave it, warn loudly.

   Also check for a stale `<install-dir>/wt-common.sh`: earlier versions of `/wtree-install` used to symlink it alongside the four binaries. The current version no longer does (the scripts walk symlinks back to the plugin dir and source it from there). If you find it as a symlink to `${CLAUDE_PLUGIN_ROOT}/scripts/wt-common.sh`, remove it with the same logic as above.

3. **Dry-run mode** (`--dry-run`): for every action above, print what would happen and exit without touching anything. Format as a table or bulleted list, not free prose.

4. **Print a tight summary.** Include:
   - Each helper that was removed, left foreign, or already absent.

## Notes

- This command does **not** uninstall the plugin itself (`/plugin uninstall git-worktree@agent-utils` does that). Run this *before* `/plugin uninstall` if you want symlink targets verified — once the plugin is gone, `${CLAUDE_PLUGIN_ROOT}` is unset and the cleanup can't tell foreign symlinks from this plugin's.
- Earlier versions of this plugin shipped a `wt-shell.sh` shell function that `/wtree-install` would source into the user's shell rc. That function was dropped because it was brittle across zsh configurations (notably `nohashdirs`). If a user upgraded across that change and still has a `# git-worktree plugin` block in their `~/.zshrc` or `~/.bashrc` referencing `wt-shell.sh`, tell them to remove those two lines manually — this command no longer touches the rc.
- If `${CLAUDE_PLUGIN_ROOT}` is unset, the plugin isn't loaded — abort with a clear message ("install the plugin again, run /wtree-uninstall, then uninstall").
- Do not blanket-`rm` anything in `<install-dir>` — only the named files. The user may have unrelated binaries there.
