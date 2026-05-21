# excalidraw-diagram

Generate Excalidraw diagrams that **argue visually** — fan-outs for one-to-many, timelines for sequences, convergence for aggregation. Includes a Playwright-based render pipeline so the agent can see its own output and fix layout defects in a loop before delivering.

Triggers automatically when the user wants to visualize workflows, architectures, or concepts as `.excalidraw` files.

## Contents

- `skills/excalidraw-diagram/SKILL.md` — design methodology + render-and-validate workflow.
- `skills/excalidraw-diagram/references/` — color palette, element templates, JSON schema, and the Playwright render script.

## First-time setup (render pipeline)

The skill ships with a render script so the agent can validate diagrams visually. Set it up once:

```bash
cd ~/.claude/plugins/.../skills/excalidraw-diagram/references
uv sync
uv run playwright install chromium
```

Or just ask your agent: *"Set up the Excalidraw diagram skill renderer."*

## Customize colors

Edit `skills/excalidraw-diagram/references/color-palette.md`. Everything else in the skill is universal design methodology.

## Install

```
/plugin install excalidraw-diagram@ed-ct-agent-utils
```

## Credits

Skill methodology adapted from [coleam00/excalidraw-diagram-skill](https://github.com/coleam00/excalidraw-diagram-skill).
