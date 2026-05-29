# git-bare-convert

Convert an existing plain `git clone` into a `.bare/` + per-branch-worktree layout, in place, without re-cloning. The current branch is re-attached as the first worktree, so no work or local-only state is lost.

Triggers on requests like "convert this clone to a bare repo", "transform this into a bare folder", "switch this repo to worktrees", "make `.git` a pointer to `.bare`", or "bare-ify this repo." Also exposes a `/git-bare-convert` slash command for explicit invocation.

## Contents

- `skills/git-bare-convert/SKILL.md` — when to load, workflow, anti-patterns, examples.
- `commands/git-bare-convert.md` — `/git-bare-convert [--yes] [--skip-cleanup]` slash command.
- `scripts/convert-to-bare.sh` — the actual conversion (atomic, idempotent, refuses on unsafe preconditions). The skill and command both delegate to this script so the whole workflow is one permission prompt.

## Install

```
/plugin install git-bare-convert@agent-utils
```

## Usage

Three equivalent ways from inside a normal clone:

1. Natural language: "convert this clone to a bare repo." Claude loads the skill, which runs the script.
2. Slash command: `/git-bare-convert` (or `/git-bare-convert --skip-cleanup` for the slash-in-branch case).
3. Direct from a real terminal: `${CLAUDE_PLUGIN_ROOT}/scripts/convert-to-bare.sh` — the script's interactive `Proceed?` prompt expects a TTY. From inside Claude Code (or any non-interactive context), pass `--yes`.

## Script flags

- `--yes` / `-y` — skip the interactive `Proceed?` prompt. Required when running from a non-TTY context (e.g. Claude Code tool execution).
- `--skip-cleanup` — don't delete the stale working-tree files at the project root after re-attaching the branch as a worktree. Use when the current branch contains `/` and other top-level dirs share the prefix.
- `--help` / `-h` — print usage.

The script refuses (exit 2) on any of these:

- Not inside a git repo, or `.git/` is not a directory (already converted, or it's a worktree).
- `.bare` already exists.
- Submodules declared in `.gitmodules`.
- Working tree is dirty.
- HEAD is detached.

## Related

- `git-worktree` plugin (`wtree` helper) — for the *fresh-bootstrap* case where there's no existing clone yet.
