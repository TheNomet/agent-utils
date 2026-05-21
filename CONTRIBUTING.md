# Contributing

Thanks for adding to the team's shared toolbox. Keep plugins small, focused, and well-described —
Claude routes work to skills/agents based on their description text, so vague descriptions hurt everyone.

## One-time setup

After cloning, install [pre-commit](https://pre-commit.com) and wire up the hooks:

```bash
brew install pre-commit          # or: pipx install pre-commit
pre-commit install -t pre-commit -t pre-push -t commit-msg
```

This activates three stages:

- **`pre-commit`** — refreshes the README plugin catalog when `marketplace.json` changes; runs hygiene checks (trailing whitespace, EOF newlines, JSON/YAML validity, shellcheck).
- **`commit-msg`** — enforces [Conventional Commit](https://www.conventionalcommits.org/) format (matches the team's `git-commit` skill).
- **`pre-push`** — final guard: re-runs the catalog updater and fails the push if anything is out of sync.

To run all hooks against the whole repo manually: `pre-commit run --all-files`.

## Add a new plugin

### 1. Scaffold from the template

```bash
cp -r templates/plugin plugins/<your-plugin>
```

Then trim it down: a plugin doesn't need every directory. Many plugins are just one skill.

### 2. Fill in `plugin.json`

`plugins/<your-plugin>/.claude-plugin/plugin.json`:

```json
{
  "name": "<your-plugin>",
  "version": "0.1.0",
  "description": "Action-oriented summary, one sentence.",
  "author": { "name": "Your Name", "email": "you@dnb.no" },
  "license": "MIT"
}
```

### 3. Write the content

- **Skills** (`skills/<name>/SKILL.md`) — frontmatter `name` + `description` are mandatory.
  The `description` is the *trigger*: list concrete user phrasings and scenarios. If Claude can't
  tell from the description when to load the skill, it won't.
- **Commands** (`commands/<name>.md`) — frontmatter `description` shows in the picker.
  Use `$ARGUMENTS` for user input.
- **Subagents** (`agents/<name>.md`) — frontmatter `name`, `description`, optional `tools`.
- **Scripts** (`scripts/`) — reference from skills/commands as `${CLAUDE_PLUGIN_ROOT}/scripts/foo.sh`.
  `chmod +x` shell scripts.

### 4. Register in the marketplace

Add an entry to `.claude-plugin/marketplace.json` under `plugins`:

```json
{
  "name": "<your-plugin>",
  "source": "./plugins/<your-plugin>",
  "description": "Same as plugin.json description.",
  "version": "0.1.0",
  "category": "<workflows|languages|quality|security|...>",
  "author": { "name": "Your Name", "email": "you@dnb.no" }
}
```

Always set `category` — `/plugin` uses it for filtering.

### 5. Refresh the README catalog

The pre-commit hook does this automatically when you commit. To run it manually:

```bash
./scripts/update-readme-catalog.sh
```

This rewrites the catalog block inside `README.md` between the `<!-- BEGIN: plugins-catalog -->` markers. Don't hand-edit that block — the hook will overwrite it.

### 6. Test locally

```
/plugin marketplace add /Users/you/projects/github/agent-utils
/plugin install <your-plugin>@ed-ct-agent-utils
```

Reload (`/plugin`) and try triggering your skill/command.

### 7. Open a PR

Bump the plugin's `version` in `plugin.json` **and** in `marketplace.json` for any user-visible change.

## Style

- Descriptions: short, action-first ("Generate Conventional Commit messages", not "A plugin that helps with...").
- Skills: include `<example>` blocks showing the exact triggering user message.
- Don't bundle secrets, API keys, or company-internal URLs in skills shipped to all members.
- Prefer many small plugins over one mega-plugin — users install only what they need.
