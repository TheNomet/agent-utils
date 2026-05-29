---
name: git-worktree
description: Single entry point for any task involving git worktrees in a bare-clone layout. Use whenever the user asks to add/create/spin-up a worktree or branch folder, list/show worktrees, remove/clean-up/delete a worktree, switch to or work on a different branch in parallel, bootstrap a new repo "with worktrees" or "the wtree setup", or operates inside a directory that contains a `.bare/` directory plus a one-line `.git` file. Also use for diagnostic asks like "which worktree am I in", "why does git status say nothing here", or "branch already checked out somewhere else". This skill routes to the right helper (`wtree`, `wta`, `wtl`, `wtr`) or slash command (`/wtree-install`, `/worktree-add`); load it first and let it dispatch.
---

# git-worktree

The bare-clone + worktree layout lets a repo be cloned **once** and worked on across many branches in parallel — each branch is a sibling folder, all sharing one git database. This skill is the dispatcher: figure out what the user wants, then call the right helper.

## Step 1: classify the request

Match the user's ask to one of these intents and jump to the matching section.

| Intent | Phrases | Go to |
|---|---|---|
| **Bootstrap** a fresh clone with the worktree layout | "set up worktrees here", "clone with the bare layout", "use the wtree workflow on this repo" | [§ Bootstrap](#bootstrap) |
| **Install** the helpers on `$PATH` | "I just installed the plugin", "set up `wta`", "put `wtree` on my path" | [§ Install helpers](#install-helpers) |
| **Uninstall** the helpers | "remove `wta` from my path", "clean up the wtree install", "I'm done with this plugin" | [§ Uninstall helpers](#uninstall-helpers) |
| **Add** a worktree (new or existing branch) | "spin up a folder for `feat/...`", "check out `<branch>` somewhere", "start a worktree on X", "work on Y in parallel" | [§ Add a worktree](#add-a-worktree) |
| **List** worktrees | "what worktrees do I have", "show my branches", "list the folders" | [§ List worktrees](#list-worktrees) |
| **Remove** a worktree | "clean up `<folder>`", "I'm done with X", "delete that branch folder" | [§ Remove a worktree](#remove-a-worktree) |
| **Diagnose** unexpected git behaviour | "why is `git status` empty", "branch is already checked out", "fatal: not a git repo" | [§ Diagnostics](#diagnostics) |
| **Update / fetch** | "pull all branches", "fetch everything" | [§ Update everything](#update-everything) |

Before doing anything else, also check:

1. **Are the helpers installed?** Run `command -v wta wtl wtr wtree` (silent on success). If any are missing, the user's `$PATH` doesn't have them — note this and either (a) use the vanilla `git worktree` equivalents documented below, or (b) suggest `/wtree-install`. Don't assume.
2. **Are we inside a bare-worktree layout?** A directory with `.bare/` AND a `.git` file (not directory) somewhere up the tree. The helpers detect this themselves; if you're falling back to vanilla git, run `git rev-parse --show-toplevel` to find the worktree root, and `cd <root>/..` to find the project root.

## Step 2: act

### Bootstrap

The user wants a brand-new bare-clone setup, typically because they're starting on a new repo.

1. Confirm the target directory is empty (the `wtree` script enforces this; if it complains, that's why).
2. Run:
   ```bash
   wtree <repo-url>
   ```
   If `wtree` isn't on `$PATH` and the user hasn't run `/wtree-install`, either install it now (with consent) or fall back to the manual sequence in [§ Vanilla equivalents](#vanilla-equivalents).
3. Create the first worktree, usually `main`:
   ```bash
   wta main
   ```
4. Tell the user where they are and what to do next.

**Don't bootstrap unsolicited.** If the user already has a layout in place, this section doesn't apply.

### Install helpers

User has installed the plugin via `/plugin install git-worktree@agent-utils` and now needs `wtree`, `wta`, `wtl`, `wtr` on `$PATH`. Run the slash command:

```
/wtree-install
```

It symlinks the four scripts plus the `wt-common.sh` library into `$HOME/.local/bin`, and warns if the install dir isn't on `$PATH`. See `commands/wtree-install.md` for the full flow.

### Uninstall helpers

User wants to remove the helpers from `$PATH` (and clean the rc source line). Run:

```
/wtree-uninstall
```

It only removes files this plugin actually installed: symlinks pointing at the plugin, or copies whose content still matches. Foreign or modified files at the same paths are left alone with a warning. The rc edit is gated on confirmation and creates a `.bak` first. Run `/wtree-uninstall --dry-run` first if you want to see exactly what would be touched. Run this **before** `/plugin uninstall git-worktree@agent-utils` — once the plugin is gone, `${CLAUDE_PLUGIN_ROOT}` is unset and the cleanup can't verify symlink targets.

### Add a worktree

The flagship case. Default to `wta`; it auto-detects whether the branch exists on origin and forks new branches from `origin/HEAD` by default. Run `wta -h` for the full form list — only the `wta <branch> .` form is worth surfacing here, because it's the easy-to-miss one.

Decision rules:

- **Branch name only** → folder name mirrors the branch (slashes preserved). Base = `origin/HEAD`. This is what 90% of asks become.
- **User explicitly names a base branch** ("off develop", "from the release branch") → pass it as the second arg.
- **User says "check out <existing-branch>"** → still just `wta <branch>`. `wta` checks origin, finds the existing branch, and uses it without `-b`. Don't add flags for this case.
- **You (the agent) are already on a non-main branch and the user asks for a sub-worktree off it** → `wta <branch> .` (or `wta --here <branch>`). This forks from the current worktree's HEAD, not from `origin/HEAD`. Common phrasing: "spin up a side experiment off this branch", "make a copy where I can try X without losing what I have".
- **Folder must differ from branch** (rare) → `wta --folder <path> <branch>`.

**Why `.` matters for agents:** `wta` runs `git` against the bare-repo root by default, where `HEAD` resolves to the bare repo's symbolic ref — not your current branch. Passing `.` (or `--here`) tells `wta` to resolve `HEAD` from your *current working directory* instead, which is the worktree the agent or user is actually in.

After `wta` finishes, the new worktree path is on the **last line of stdout** (progress messages go to stderr).

**Important: the script can't `cd` for you.** A plain script runs in a subprocess; its working directory dies with it. The plugin used to ship a shell function for auto-cd but it was too brittle across zsh configurations (notably `nohashdirs`), so it was dropped. Both humans and agents now use the same explicit pattern:

- For **interactive humans**: wrap the call in `cd "$(...)"` so the shell substitutes the path:

  ```bash
  cd "$(wta feat/foo)"
  ```

- For **agents** (you): capture stdout's last line and `cd` explicitly so subsequent commands run in the right directory:

  ```bash
  NEW_WORKTREE=$("${CLAUDE_PLUGIN_ROOT}/scripts/wta" <args> | tail -n1) \
    && cd "$NEW_WORKTREE"
  ```

  Or invoke `/worktree-add <args>` instead of `wta` directly — the slash command bundles the verify + run + capture + `cd` + report cycle.

### List worktrees

```bash
wtl
```

Output is `<path>  <branch>  <last-commit-subject>`. Use this to answer "what do I have", "where's branch X", "which folder has uncommitted work" (combine with a follow-up `git -C <path> status --short`).

Vanilla fallback: `git worktree list`.

### Remove a worktree

Default to `wtr <path>`. Run `wtr -h` for the full flag list. Decision rules:

- **User said "clean up X"** with no other context → `wtr <path>` only. Don't delete the branch unless they ask.
- **User said "I'm done with X, it's merged"** → `wtr <path> --delete-branch`. The merge check is enforced by `wtr` itself; if it refuses, the branch isn't actually merged into `origin/HEAD` and you should tell the user, not paper over it with `--force`.
- **User said "blow it away, I have changes I don't want"** → `wtr <path> --force`.
- **User wants to delete the folder manually** → don't. `rm -rf` leaves dangling worktree records. Always go through `wtr` (or `git worktree remove` + `git worktree prune` if helpers aren't installed).

### Diagnostics

| Symptom | Cause | Fix |
|---|---|---|
| `git status` shows nothing or "not a git repository" at the project root | You're in the bare root (the dir with `.bare/`), which has no working tree | `cd` into a branch folder, or run `wtl` to see what's available |
| `fatal: '<branch>' is already checked out at '<path>'` when adding a worktree | A branch can only be checked out in one worktree at a time | `wtl` to find it; either work there or `wtr <path>` first |
| `git fetch` only updates one branch on a fresh bootstrap | The bare clone wasn't reconfigured to fetch all remote heads | `git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*" && git fetch --all` (the `wtree` script does this; if you bootstrapped manually, do it now) |
| `git worktree list` shows a stale entry for a folder that no longer exists | Folder was `rm -rf`'d without `git worktree remove` | `git worktree prune` |
| `command -v wta` returns nothing | Helpers not installed, or install dir not on `$PATH` | Run `/wtree-install`; it warns about `$PATH` |

### Update everything

```bash
git fetch --all --prune          # from any worktree
```

Each worktree pulls its own branch independently:

```bash
cd <worktree> && git pull
```

There is no helper for "update every worktree" because most users don't want that — stale branches are usually fine.

---

## Reference

### The layout

```
my-repo/
├── .bare/                  # the real git database (a bare clone)
├── .git                    # one-line file: "gitdir: ./.bare"
├── main/                   # worktree tracking origin/main
├── feat/EDM-1234-thing/    # worktree on a feature branch
└── fix/hotfix-42/          # worktree on another branch
```

- `.bare/` holds objects, refs, config — the source of truth.
- The top-level `.git` is **not** a directory; it's a file with the single line `gitdir: ./.bare`. Tooling that walks up looking for `.git` finds it; the actual storage is in `.bare/`.
- Each branch folder is a real working tree created with `git worktree add`. They share the bare repo's objects, so disk usage stays small even with many branches.
- Per-worktree config goes in `.bare/worktrees/<name>/config.worktree`. Hooks in `.bare/hooks/` apply to every worktree.

Detect the layout by running `ls -la` at the project root: you'll see both `.bare/` and a `.git` file (not directory). Read `.git` and it should say `gitdir: ./.bare`.

### Helper inventory

| Helper | What it wraps |
|---|---|
| `wtree <url>` | `git clone --bare` + `.git` pointer + fetch refspec + `fetch --all` |
| `wta <branch> [base]` | `git worktree add [-b <branch>] <folder> <base>`, auto-detects existing remote branches |
| `wtl` | `git worktree list --porcelain`, reformatted as path · branch · subject |
| `wtr <path> [flags]` | `git worktree remove` + `git worktree prune` (+ optional `git branch -d` with merge check) |

All four walk up to find the bare-clone root automatically — run them from any worktree, not just the project root.

### Vanilla equivalents

When helpers aren't installed:

```bash
# bootstrap (run inside an empty directory)
git clone --bare <url> .bare
echo "gitdir: ./.bare" > .git
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch --all

# add (existing remote branch)
git worktree add <path> <branch>

# add (new branch off origin/main)
git worktree add -b <new-branch> <path> origin/main

# list
git worktree list

# remove
git worktree remove <path> && git worktree prune
```

Mirror branch slashes in the folder path (`feat/foo` → folder `feat/foo`) so the tree stays parallel to the branch namespace.

### Working as an agent inside this layout

- **Always know which worktree you're in.** `pwd` and `git rev-parse --show-toplevel` answer the question. Commands like `git status` reflect the current worktree's branch only.
- **The bare root is not a working tree.** No checked-out code there; `git status` will look broken. Move into a branch folder.
- **One branch per worktree.** Don't `git checkout other-branch` inside an existing worktree to switch — that's the friction worktrees exist to remove. Create a new worktree with `wta` instead.
- **A branch lives in at most one worktree.** If `wta` (or `git worktree add`) complains a branch is already checked out, find it with `wtl` and either work there or remove it first.

## Source

Pattern adapted from <https://dev.to/metal3d/git-worktree-like-a-boss-2j1b>. The `wtree` script is a thin wrapper around the steps in that post; `wta`, `wtl`, `wtr` are this plugin's additions.
