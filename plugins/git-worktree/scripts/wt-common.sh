#!/usr/bin/env bash
# wt-common.sh — shared helpers for the git-worktree plugin scripts.
# Sourced, never executed directly.

# Walk up from $PWD looking for the bare-worktree root: a directory containing
# both a `.bare/` directory and a `.git` file (not directory) that points at it.
# Echoes the absolute path on success; non-zero exit if not found.
wt_find_root() {
    local dir
    dir=$(pwd -P)
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.bare" ] && [ -f "$dir/.git" ]; then
            printf '%s\n' "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Echo the remote's default branch ref, e.g. "origin/main".
# Tries `origin/HEAD` symref first; falls back to a `git ls-remote` query.
wt_default_base() {
    local root="$1"
    local ref
    ref=$(git -C "$root" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null) || true
    if [ -n "$ref" ]; then
        printf '%s\n' "${ref#refs/remotes/}"
        return 0
    fi
    # Fallback: ask the remote, then set the symref locally for next time.
    local head
    head=$(git -C "$root" ls-remote --symref origin HEAD 2>/dev/null \
           | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2; exit}')
    if [ -n "$head" ]; then
        git -C "$root" symbolic-ref refs/remotes/origin/HEAD "refs/remotes/origin/$head" 2>/dev/null || true
        printf 'origin/%s\n' "$head"
        return 0
    fi
    return 1
}

wt_branch_exists_on_origin() {
    git -C "$1" show-ref --verify --quiet "refs/remotes/origin/$2"
}

wt_branch_exists_locally() {
    git -C "$1" show-ref --verify --quiet "refs/heads/$2"
}

# Print to stderr (so stdout stays clean for capture by shell wrappers).
wt_log() {
    printf '%s\n' "$*" >&2
}

wt_die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}
