---
name: git-commit
description: Write Conventional Commit messages with a tight, why-focused body. Use whenever the user asks to commit, write a commit message, prepare or finalize a commit, squash, or amend — and use this proactively before running `git commit` so the message follows house style instead of the LLM's default verbose tendencies. Also use when the user shares draft commit text and asks for cleanup, or when reviewing whether a commit message is good. Trigger even on short asks like "commit this", "commit", "wrap it up", "squash these", because the LLM's untriggered default is to write 50-line essays that nobody reads.
---

# git-commit

Write Conventional Commit messages that match what experienced engineers actually merge — short, why-focused, never a transcript of the diff.

## When this matters

The default behaviour without this skill is to write a commit body that mirrors the structure of the change: every file, every test, every config knob in a flat outline. Reviewers skim those once, never reread, and they bloat `git log` views forever. The PR description is where exhaustive detail belongs; the commit message is where the *reason* belongs.

Use this skill whenever a commit is being written or revised — including when no human asked, e.g. when wrapping up an autonomous task and the next step is `git commit`. If unsure whether the body is needed at all, prefer subject-only.

## Subject line

Format:

```
<type>(<scope>): <subject>
```

Or, when no scope makes sense:

```
<type>: <subject>
```

### Type

One of: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `perf`, `style`, `build`. Pick the most accurate. If the commit changes behaviour visible to a user, it's `feat` or `fix`, not `refactor`.

### Scope

Pick the **first applicable** option:

1. **Jira ticket ID** if one exists for the work. Prefer parsing it from the current branch name (e.g. branches like `feat/EDM-11584_pr_approvers_ed_ct_team`, `fix/MINBANK-44105-empty-confidence`, `EDM-7973/fix-tz` all yield `EDM-11584`, `MINBANK-44105`, `EDM-7973`). The pattern is typically `[A-Z]+-\d+`. If multiple IDs appear, pick the one that names the *work*, usually the first.
2. **Module / team / area identifier** if no Jira ID is available (e.g. `ctd`, `workflow`, `auth`, `parser`, `README`).
3. **Omit the scope entirely** if no concise identifier fits — `feat: <subject>` is correct and common.

Do **not** invent a Jira ID. If the branch name doesn't carry one and the user didn't supply one, skip step 1 entirely.

### Subject text

- **≤ 72 characters** for the whole subject line including type and scope.
- **Imperative mood** ("add", "fix", "drop", "switch") — read it as completing the sentence "If applied, this commit will <subject>".
- **Lowercase first word** after the colon.
- **No trailing period.**

## Body

The body is optional but should exist for any commit that isn't trivially self-evident from the subject.

### Length

Aim for **≤ 20 lines**. If the body wants to be longer, that material almost always belongs in the PR description, not the commit message. A long commit body is a smell that the commit is doing too many things or that the writer is performing thoroughness for an audience that won't read it.

### Shape

**2 to 4 short paragraphs.** Each paragraph one idea:

- *Why* the change is being made (the problem, the gap, the policy decision).
- *What* the change does, at a level a future maintainer with no context can act on. Behaviour-level, not file-level.
- *Notable consequences* — config knobs flipped, compatibility breaks, follow-ups deferred.

Bullets are allowed sparingly when there are 2–4 genuinely independent groupings of change in a single commit. Don't nest bullet sections like "Tests / Workflow / Prod policy" — that's a mini PR description.

### Trailers

If a Jira (or other ticket-tracker) ID exists, append a trailer at the very bottom:

```
Refs EDM-11584
```

Use `Refs` (or `Closes` / `Fixes` if the commit fully resolves the ticket and the team's convention permits auto-close). Only include a trailer if the ID actually exists and is the relevant one — don't fabricate one.

## Anti-patterns to avoid

These are the moves to consciously not make:

- **Don't list every file changed.** The diff already does that. Talk about *behaviour*, not file paths.
- **Don't include test counts, coverage percentages, or "X tests pass".** That's a CI artefact and a PR-description detail. The body talks about the change itself.
- **Don't paste code snippets, sample output, or rendered template fragments** into the commit body. If a future reader needs to see the new behaviour, point them to a test.
- **Don't fabricate a Jira ID** to give the commit a scope or a `Refs` trailer. Omit instead.
- **No emojis.** Match standard `git log` aesthetics; emojis hurt scannability and don't survive every git tool.
- **Don't wrap multiple unrelated changes** into one commit just so the body can hand-wave over them. If the body needs a "Prod policy" / "Workflow" / "Tests" outline, the commit is probably two or three commits.

## Workflow when generating a commit

1. **Read the staged diff.** `git diff --cached` (or `git diff` if nothing's staged yet — but staged is the source of truth). Do NOT skip this. The subject and body must reflect what's actually being committed.
2. **Skim recent commit history** in the same repo: `git log --oneline -10` and inspect the last 2–3 full messages with `git log -3`. Match the local conventions (e.g. some repos use `chore(ci):` while others use `ci:`; some always carry `Refs`, others never do).
3. **Parse the branch name** for a Jira-style ID. If found, that's your scope. If not, pick a module/area identifier from the diff (the most-touched directory or component is usually right). If nothing fits, drop the scope.
4. **Draft the subject** under 72 chars, imperative.
5. **Decide if a body is needed.** Single-line refactors, doc tweaks, dependency bumps usually don't need one. If yes, write 2–4 short paragraphs answering *why*.
6. **Sanity-check against the anti-patterns** above. If the body has bullet headings like "Tests / Workflow / Prod policy", or quotes any test counts, cut those.
7. **Commit.** Don't include `Co-Authored-By: Claude <noreply@anthropic.com>` or similar attribution trailers unless the user has asked for them.

## Examples

### Example 1 — small fix with a Jira ID in the branch

Branch: `fix/MINBANK-44105-empty-confidence`
Diff: one-line guard added in `services/confidence_handler.py`.

```
fix(MINBANK-44105): handle empty confidence level in API response

The confidence handler crashed with a KeyError when downstream services
sent an empty string instead of omitting the field. Treat empty as
absent so the response defaults to 'unknown' instead of 500-ing.

Refs MINBANK-44105
```

### Example 2 — refactor, no ticket, no clear scope

Branch: `refactor/cleanup-helpers`
Diff: rename three helpers, no behaviour change.

```
refactor: rename internal helpers for clarity

`do_thing`, `do_thing_2`, and `helper` were ambiguous at the call sites
and had drifted from what they actually returned. Rename to verbs that
describe the result. No behaviour change; call sites updated in lockstep.
```

### Example 3 — feature with a clear team scope

Branch: `feat/add-slack-notifier`
Diff: new `slack_notifier.py` plus wiring in two existing modules; team folder is `notifications/`.

```
feat(notifications): send a Slack message on deployment success

Operators currently have to tail CI logs to know when a deploy lands.
Post a single message to the team channel with the release tag and a
link to the run, gated by an env var so non-prod runs stay silent.

The webhook URL is read from SLACK_WEBHOOK_URL; absence of the var is a
no-op rather than a hard error so smoke-tests don't need it.
```

### Example 4 — subject only

Branch: anything.
Diff: bumped a single dependency in `pyproject.toml` from `requests==2.32.4` to `requests==2.32.5`.

```
chore: bump requests to 2.32.5
```

No body needed. The subject says everything.

### Example 5 — what NOT to write

This is the kind of body to actively trim down:

```
feat(ctd): annotate changelog entries with PR approvers in CRQ description

Each bullet in the latest CTD CHANGELOG.md release section is now
enriched with the GitHub usernames who approved the merging PR, so a
CRQ reviewer can audit the approval trail at a glance:

  - **EDM-9648**: ... (#144) _(approved by @alice, @bob)_

How it works
- teams/ctd/setup.py parses the trailing (#NNN) on each
  - **JIRA-X**: ... bullet of the latest version section.
- src/github_api.py issues a single REST call per PR ...
[40 more lines of how-it-works, sample output, test counts]

Refs EDM-11584
```

The why is buried; the rest is PR-description content. Trimmed:

```
feat(EDM-11584): annotate CTD changelog entries with PR approvers

CRQ reviewers currently have no in-document signal of who approved each
PR in a release. Parse the trailing `(#NNN)` from every changelog bullet,
look up the approving reviewers via the GitHub REST API, and append an
inline italic suffix so the approval trail is visible at a glance.

The lookup is best-effort and never blocks CRQ creation: a transient
GitHub error renders as `_(approver lookup failed)_` rather than failing
the pipeline. Works on both public github.com and GitHub Enterprise via
the runner's GITHUB_API_URL.

Also opts CTD into the `Automated (preapproved)` chg_model in prod, now
that the team has the formal pre-approval. A new `_PROD_PREAPPROVED_TEAMS`
allowlist keeps the strict default for every other team.

Refs EDM-11584
```

Same information for anyone who actually needs context, ⅓ the length, no
file lists, no metrics.

## Self-check before committing

Before writing the message to disk, re-read it against this checklist:

- Subject ≤72 chars? Imperative? Lowercase? No trailing period?
- Scope correct (Jira > module > none)?
- Body answers *why*, not *what file*?
- Under ~20 lines?
- No test counts, no coverage, no file enumerations, no code snippets, no emojis?
- `Refs <ID>` only if the ID actually exists?

If any answer is "no", revise before running `git commit`.
