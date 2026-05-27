#!/usr/bin/env bash
# convert-to-bare.sh
#
# Convert an existing plain `git clone` (with a top-level `.git/` directory)
# into a `.bare/` + worktrees layout, in place, without re-cloning.
#
# Layout produced:
#
#   <repo>/
#   ├── .bare/              # bare git database
#   ├── .git                # one-line file: "gitdir: ./.bare"
#   └── <current-branch>/   # the existing checkout, re-attached as a worktree
#
# Run from inside the cloned repo (anywhere under the project root).
#
# Flags:
#   --skip-cleanup    Do not delete the stale working-tree files at the project
#                     root (step 5). Use when the current branch contains '/'
#                     and you want to eyeball the project root manually first.
#   --yes / -y        Skip the final confirmation prompt.
#   --help / -h       Print this help and exit.
#
# Exit codes:
#   0   success
#   1   generic error / aborted by user
#   2   precondition failed (not a clone, dirty tree, detached HEAD, etc.)

set -euo pipefail

print_help() {
  sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
}

SKIP_CLEANUP=0
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-cleanup) SKIP_CLEANUP=1 ;;
    --yes|-y)       ASSUME_YES=1 ;;
    --help|-h)      print_help; exit 0 ;;
    *)              echo "error: unknown flag: $1" >&2; exit 1 ;;
  esac
  shift
done

err() { printf 'error: %s\n' "$*" >&2; }
note() { printf '%s\n' "$*"; }

# ---- Locate the project root --------------------------------------------------

if ! command -v git >/dev/null 2>&1; then
  err "git is not on PATH"
  exit 2
fi

if ! toplevel="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  err "not inside a git repository"
  exit 2
fi

cd "$toplevel"

# ---- Pre-flight checks --------------------------------------------------------

if [[ ! -d .git ]]; then
  err ".git/ is not a directory at $toplevel"
  err "this script only converts plain clones; this repo is not one"
  exit 2
fi

if [[ -e .bare ]]; then
  err ".bare already exists at $toplevel — repo looks already converted"
  exit 2
fi

if [[ -f .gitmodules ]]; then
  err "this repo declares submodules in .gitmodules"
  err "submodule re-init inside the new worktree is not handled by this script"
  err "review and run the conversion by hand, or remove the submodules first"
  exit 2
fi

# Refuse on a dirty tree. Step 5 deletes the project-root copy of tracked files;
# any uncommitted/untracked work in the root would be lost.
if [[ -n "$(git status --porcelain)" ]]; then
  err "working tree is not clean — commit or stash first, then re-run"
  git status --short
  exit 2
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" == "HEAD" ]]; then
  err "HEAD is detached; check out a named branch before converting"
  exit 2
fi

top_component="${current_branch%%/*}"
slash_warning=0
if [[ "$current_branch" == */* ]]; then
  slash_warning=1
fi

# ---- Show the plan ------------------------------------------------------------

note "Project root:   $toplevel"
note "Current branch: $current_branch"
note ""
note "Plan:"
note "  1. git fetch --all"
note "  2. mv .git .bare"
note "  3. configure .bare as a bare repo and set the standard fetch refspec"
note "  4. write '.git' pointer file containing 'gitdir: ./.bare'"
note "  5. git fetch --all   (populate refs/remotes/origin/*)"
note "  6. git worktree add '$current_branch' '$current_branch'"
if [[ $SKIP_CLEANUP -eq 1 ]]; then
  note "  7. SKIP cleanup of stale working-tree files (--skip-cleanup)"
else
  note "  7. remove stale working-tree files at the project root"
  note "     (keeps: .bare, .git, $top_component/)"
fi

if [[ $slash_warning -eq 1 && $SKIP_CLEANUP -eq 0 ]]; then
  note ""
  note "WARNING: branch '$current_branch' contains '/'."
  note "         step 7 will keep ANY top-level dir named '$top_component/'."
  note "         if unrelated dirs share that prefix, re-run with --skip-cleanup"
  note "         and clean up by hand."
  # List potential collisions to help the user decide.
  collisions=()
  while IFS= read -r entry; do
    name="${entry#./}"
    [[ "$name" == ".bare" || "$name" == ".git" || "$name" == "$top_component" ]] && continue
    [[ "$name" == "$top_component"* ]] && collisions+=("$name")
  done < <(find . -maxdepth 1 -mindepth 1 -printf './%P\n' 2>/dev/null || find . -maxdepth 1 -mindepth 1)
  if [[ ${#collisions[@]} -gt 0 ]]; then
    note ""
    note "         top-level entries starting with '$top_component':"
    for c in "${collisions[@]}"; do note "           $c"; done
  fi
fi

# ---- Confirm ------------------------------------------------------------------

if [[ $ASSUME_YES -ne 1 ]]; then
  if [[ ! -t 0 ]]; then
    err "stdin is not a terminal — cannot prompt for confirmation"
    err "re-run with --yes if you've already seen the plan and approve it"
    exit 1
  fi
  note ""
  read -r -p "Proceed? [y/N] " reply
  case "$reply" in
    y|Y|yes|YES) ;;
    *) err "aborted"; exit 1 ;;
  esac
fi

# ---- Conversion ---------------------------------------------------------------

note ""
note "[1/7] git fetch --all"
git fetch --all

note "[2/7] mv .git .bare"
mv .git .bare

note "[3/7] configure .bare as bare with standard fetch refspec"
git --git-dir=.bare config --bool core.bare true
git --git-dir=.bare config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

note "[4/7] write .git pointer"
printf 'gitdir: ./.bare\n' > .git

note "[5/7] git fetch --all (re-populate remote-tracking refs)"
git fetch --all

note "[6/7] git worktree add '$current_branch' '$current_branch'"
git worktree add "$current_branch" "$current_branch"

if [[ $SKIP_CLEANUP -eq 1 ]]; then
  note "[7/7] skipped cleanup (--skip-cleanup)"
else
  note "[7/7] remove stale working-tree files at the project root"
  find . -maxdepth 1 -mindepth 1 \
    ! -name .bare ! -name .git ! -name "$top_component" \
    -exec rm -rf {} +
fi

# ---- Verification -------------------------------------------------------------

note ""
note "Verification:"
git worktree list
note ""
note "  .git contents: $(cat .git)"
note "  bare repo:     $(git --git-dir=.bare rev-parse --is-bare-repository)"
note ""
note "Done. cd into ./$current_branch/ to keep working."
