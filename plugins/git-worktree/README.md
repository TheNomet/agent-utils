# git-worktree

Bootstrap and operate a bare-clone + worktree layout, so multiple branches live as sibling folders off a single repo and agents stay scoped to their own working tree.

## Contents

- `skills/git-worktree/SKILL.md` — how to recognize the layout, add/remove worktrees, and avoid the common foot-guns.
- `scripts/wtree` — bootstrap a new bare-clone layout. Run inside an empty directory.
- `scripts/wta` — add a worktree: `wta <branch> [base]`. Folder name = branch by default; base defaults to `origin/HEAD`. Detects existing remote branches and checks them out instead of creating duplicates. Prints the new worktree path on the last line of stdout so callers can do `cd "$(wta <branch>)"`.
- `scripts/wtl` — pretty `git worktree list` (path · branch · last-commit subject).
- `scripts/wtr` — remove a worktree, optionally with `--delete-branch` for merged branches.
- `scripts/wt-common.sh` — shared library, sourced by the four scripts via a symlink-walking lookup so it stays in the plugin dir even after `/wtree-install` symlinks the binaries elsewhere.
- `commands/wtree-install.md` — `/wtree-install` slash command. Symlinks every helper into `$HOME/.local/bin`.
- `commands/wtree-uninstall.md` — `/wtree-uninstall` slash command. Removes the symlinks (or copies that still match the plugin).
- `commands/worktree-add.md` — `/worktree-add` slash command. Lets the agent spin up a new worktree and continue work inside it.

## Install

```
/plugin install git-worktree@ed-ct-agent-utils
/wtree-install
```

The first line installs the plugin (skill + scripts + slash commands). The second line symlinks `wtree`, `wta`, `wtl`, `wtr` into `~/.local/bin/` (override with `--dir`, or `--copy` for stable files). The shared library `wt-common.sh` stays in the plugin dir; the scripts walk symlinks to find it.

## Typical workflow

```bash
mkdir my-repo && cd my-repo
wtree git@dnb.ghe.com:org/my-repo.git     # bootstrap
cd "$(wta main)"                           # first worktree, cd into it
cd "$(wta feat/EDM-1234)"                  # new branch off origin/HEAD, cd into it
# ... do work ...
wtl                                        # list everything
wtr feat/EDM-1234 --delete-branch          # clean up after merge
```

`wta` prints the new worktree path on stdout's last line and progress to stderr, so wrapping it in `cd "$(...)"` is the idiomatic pattern. There's no auto-`cd` shell function — earlier versions shipped one but it broke under common zsh configurations and the explicit `cd "$(...)"` is short enough to live with.

## Letting the agent drive

Inside Claude Code, you can also delegate:

```
/worktree-add feat/EDM-1234 origin/develop
```

The agent verifies the layout, runs `wta`, captures stdout's last line, `cd`s into the new folder, and continues whatever you actually wanted to do.

## Source

Pattern adapted from <https://dev.to/metal3d/git-worktree-like-a-boss-2j1b>.
