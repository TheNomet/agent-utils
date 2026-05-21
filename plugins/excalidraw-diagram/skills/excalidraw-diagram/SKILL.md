---
name: excalidraw-diagram
description: Create Excalidraw diagram JSON files that make visual arguments. Use when the user wants to visualize workflows, architectures, or concepts.
---

# Excalidraw Diagram Creator

Generate `.excalidraw` JSON files that **argue visually**, not just display information.

**Setup:** If the user asks you to set up this skill (renderer, dependencies, etc.), see the **First-Time Setup** section near the bottom of this file, or the plugin's top-level `README.md`.

## Customization

**All colors and brand-specific styles live in one file:** `references/color-palette.md`. Read it before generating any diagram and use it as the single source of truth for all color choices — shape fills, strokes, text colors, evidence artifact backgrounds, everything.

To make this skill produce diagrams in your own brand style, edit `color-palette.md`. Everything else in this file is universal design methodology and Excalidraw best practices.

---

## Core Philosophy

**Diagrams should ARGUE, not DISPLAY.**

A diagram isn't formatted text. It's a visual argument that shows relationships, causality, and flow that words alone can't express. The shape should BE the meaning.

**The Isomorphism Test**: If you removed all text, would the structure alone communicate the concept? If not, redesign.

**The Education Test**: Could someone learn something concrete from this diagram, or does it just label boxes? A good diagram teaches—it shows actual formats, real event names, concrete examples.

---

## Depth Assessment (Do This First)

Before designing, determine what level of detail this diagram needs:

### Simple/Conceptual Diagrams
Use abstract shapes when:
- Explaining a mental model or philosophy
- The audience doesn't need technical specifics
- The concept IS the abstraction (e.g., "separation of concerns")

### Comprehensive/Technical Diagrams
Use concrete examples when:
- Diagramming a real system, protocol, or architecture
- The diagram will be used to teach or explain (e.g., YouTube video)
- The audience needs to understand what things actually look like
- You're showing how multiple technologies integrate

**For technical diagrams, you MUST include evidence artifacts** (see below).

---

## Research Mandate (For Technical Diagrams)

**Before drawing anything technical, research the actual specifications.**

If you're diagramming a protocol, API, or framework:
1. Look up the actual JSON/data formats
2. Find the real event names, method names, or API endpoints
3. Understand how the pieces actually connect
4. Use real terminology, not generic placeholders

Bad: "Protocol" → "Frontend"
Good: "AG-UI streams events (RUN_STARTED, STATE_DELTA, A2UI_UPDATE)" → "CopilotKit renders via createA2UIMessageRenderer()"

**Research makes diagrams accurate AND educational.**

---

## Evidence Artifacts

Evidence artifacts are concrete examples that prove your diagram is accurate and help viewers learn. Include them in technical diagrams.

**Types of evidence artifacts** (choose what's relevant to your diagram):

| Artifact Type | When to Use | How to Render |
|---------------|-------------|---------------|
| **Code snippets** | APIs, integrations, implementation details | Dark rectangle + syntax-colored text (see color palette for evidence artifact colors) |
| **Data/JSON examples** | Data formats, schemas, payloads | Dark rectangle + colored text (see color palette) |
| **Event/step sequences** | Protocols, workflows, lifecycles | Timeline pattern (line + dots + labels) |
| **UI mockups** | Showing actual output/results | Nested rectangles mimicking real UI |
| **Real input content** | Showing what goes IN to a system | Rectangle with sample content visible |
| **API/method names** | Real function calls, endpoints | Use actual names from docs, not placeholders |

**Example**: For a diagram about a streaming protocol, you might show:
- The actual event names from the spec (not just "Event 1", "Event 2")
- A code snippet showing how to connect
- What the streamed data actually looks like

**Example**: For a diagram about a data transformation pipeline:
- Show sample input data (actual format, not "Input")
- Show sample output data (actual format, not "Output")
- Show intermediate states if relevant

The key principle: **show what things actually look like**, not just what they're called.

---

## Multi-Zoom Architecture

Comprehensive diagrams operate at multiple zoom levels simultaneously. Think of it like a map that shows both the country borders AND the street names.

### Level 1: Summary Flow
A simplified overview showing the full pipeline or process at a glance. Often placed at the top or bottom of the diagram.

*Example*: `Input → Processing → Output` or `Client → Server → Database`

### Level 2: Section Boundaries
Labeled regions that group related components. These create visual "rooms" that help viewers understand what belongs together.

*Example*: Grouping by responsibility (Backend / Frontend), by phase (Setup / Execution / Cleanup), or by team (User / System / External)

### Level 3: Detail Inside Sections
Evidence artifacts, code snippets, and concrete examples within each section. This is where the educational value lives.

*Example*: Inside a "Backend" section, you might show the actual API response format, not just a box labeled "API Response"

**For comprehensive diagrams, aim to include all three levels.** The summary gives context, the sections organize, and the details teach.

### Bad vs Good

| Bad (Displaying) | Good (Arguing) |
|------------------|----------------|
| 5 equal boxes with labels | Each concept has a shape that mirrors its behavior |
| Card grid layout | Visual structure matches conceptual structure |
| Icons decorating text | Shapes that ARE the meaning |
| Same container for everything | Distinct visual vocabulary per concept |
| Everything in a box | Free-floating text with selective containers |

### Simple vs Comprehensive (Know Which You Need)

| Simple Diagram | Comprehensive Diagram |
|----------------|----------------------|
| Generic labels: "Input" → "Process" → "Output" | Specific: shows what the input/output actually looks like |
| Named boxes: "API", "Database", "Client" | Named boxes + examples of actual requests/responses |
| "Events" or "Messages" label | Timeline with real event/message names from the spec |
| "UI" or "Dashboard" rectangle | Mockup showing actual UI elements and content |
| ~30 seconds to explain | ~2-3 minutes of teaching content |
| Viewer learns the structure | Viewer learns the structure AND the details |

**Simple diagrams** are fine for abstract concepts, quick overviews, or when the audience already knows the details. **Comprehensive diagrams** are needed for technical architectures, tutorials, educational content, or when you want the diagram itself to teach.

---

## Container vs. Free-Floating Text

**Not every piece of text needs a shape around it.** Default to free-floating text. Add containers only when they serve a purpose.

| Use a Container When... | Use Free-Floating Text When... |
|------------------------|-------------------------------|
| It's the focal point of a section | It's a label or description |
| It needs visual grouping with other elements | It's supporting detail or metadata |
| Arrows need to connect to it | It describes something nearby |
| The shape itself carries meaning (decision diamond, etc.) | Typography alone creates sufficient hierarchy |
| It represents a distinct "thing" in the system | It's a section title, subtitle, or annotation |

**Typography as hierarchy**: Use font size, weight, and color to create visual hierarchy without boxes. A 28px title doesn't need a rectangle around it.

**The container test**: For each boxed element, ask "Would this work as free-floating text?" If yes, remove the container.

### Labels vs. Annotations

Not all text is the same. Distinguish between:

| Text Type | Placement | Example |
|-----------|-----------|---------|
| **Component label** | **Inside** the shape (`containerId`) | "Lambda: Unpack 0165" inside a rectangle |
| **Section title** | Free-floating, positioned above the region | "BATCH INGESTION PATH" |
| **Annotation/detail** | Free-floating, near the element it describes | "Retry: 3 attempts, 20s backoff" |
| **Arrow label** | Free-floating, positioned along the arrow path | "Avro + CloudEvents" |

**Rule**: Component labels must always be inside their shape — never as a separate text box overlaid on top. Use `containerId` binding so the text moves with the shape. Section titles and annotations can float.

---

## Design Process (Do This BEFORE Generating JSON)

### Step 0: Assess Depth Required
Before anything else, determine if this needs to be:
- **Simple/Conceptual**: Abstract shapes, labels, relationships (mental models, philosophies)
- **Comprehensive/Technical**: Concrete examples, code snippets, real data (systems, architectures, tutorials)

**If comprehensive**: Do research first. Look up actual specs, formats, event names, APIs.

### Step 1: Understand Deeply
Read the content. For each concept, ask:
- What does this concept **DO**? (not what IS it)
- What relationships exist between concepts?
- What's the core transformation or flow?
- **What would someone need to SEE to understand this?** (not just read about)

### Step 2: Map Concepts to Patterns
For each concept, find the visual pattern that mirrors its behavior:

| If the concept... | Use this pattern |
|-------------------|------------------|
| Spawns multiple outputs | **Fan-out** (radial arrows from center) |
| Combines inputs into one | **Convergence** (funnel, arrows merging) |
| Has hierarchy/nesting | **Tree** (lines + free-floating text) |
| Is a sequence of steps | **Timeline** (line + dots + free-floating labels) |
| Loops or improves continuously | **Spiral/Cycle** (arrow returning to start) |
| Is an abstract state or context | **Cloud** (overlapping ellipses) |
| Transforms input to output | **Assembly line** (before → process → after) |
| Compares two things | **Side-by-side** (parallel with contrast) |
| Separates into phases | **Gap/Break** (visual separation between sections) |

### Step 3: Ensure Variety
For multi-concept diagrams: **each major concept must use a different visual pattern**. No uniform cards or grids.

### Step 4: Sketch the Flow
Before JSON, mentally trace how the eye moves through the diagram. There should be a clear visual story.

### Step 5: Plan Layout Regions
Before writing any JSON, plan the canvas layout. Define named regions with coordinate ranges so you know where each section lives. This prevents the #1 time sink: reworking spacing after the fact.

**Example layout plan:**
```
Canvas: ~1900 x 2100
Region A  (x: 10-920,   y: 80-1250):   Batch Ingestion Path
Region B  (x: 950-1870, y: 80-1050):   Event/Stream Path
Region C  (x: 10-1870,  y: 1300-2100): Database Layer (full width)
Gap between A/B and C: ~50px vertical
```

For each region, note:
- What elements go inside it
- Whether it needs a grouping frame (low-opacity background)
- The approximate vertical space needed (count elements × height + spacing)

This step takes 2 minutes and saves 20 minutes of coordinate adjustments later.

### Step 6: Generate JSON
Only now create the Excalidraw elements. **See below for how to handle large diagrams.**

### Step 7: Render & Validate (MANDATORY)
After generating the JSON, you MUST run the render-view-fix loop until the diagram looks right. This is not optional — see the **Render & Validate** section below for the full process.

---

## Large / Comprehensive Diagram Strategy

**For comprehensive or technical diagrams, you MUST build the JSON one section at a time.** Do NOT attempt to generate the entire file in a single pass. This is a hard constraint — Claude Code has a ~32,000 token output limit per response, and a comprehensive diagram easily exceeds that in one shot. Even if it didn't, generating everything at once leads to worse quality. Section-by-section is better in every way.

### The Section-by-Section Workflow

**Phase 1: Build each section**

1. **Create the base file** with the JSON wrapper (`type`, `version`, `appState`, `files`) and the first section of elements.
2. **Add one section per edit.** Each section gets its own dedicated pass — take your time with it. Think carefully about the layout, spacing, and how this section connects to what's already there.
3. **Use descriptive string IDs** (e.g., `"trigger_rect"`, `"arrow_fan_left"`) so cross-section references are readable.
4. **Namespace seeds by section** (e.g., section 1 uses 100xxx, section 2 uses 200xxx) to avoid collisions.
5. **Update cross-section bindings** as you go. When a new section's element needs to bind to an element from a previous section (e.g., an arrow connecting sections), edit the earlier element's `boundElements` array at the same time.

**Phase 2: Review the whole**

After all sections are in place, read through the complete JSON and check:
- Are cross-section arrows bound correctly on both ends?
- Is the overall spacing balanced, or are some sections cramped while others have too much whitespace?
- Do IDs and bindings all reference elements that actually exist?

Fix any alignment or binding issues before rendering.

**Phase 3: Render & validate**

Now run the render-view-fix loop from the Render & Validate section. This is where you'll catch visual issues that aren't obvious from JSON — overlaps, clipping, imbalanced composition.

### Section Boundaries

Plan your sections around natural visual groupings from the diagram plan. A typical large diagram might split into:

- **Section 1**: Entry point / trigger
- **Section 2**: First decision or routing
- **Section 3**: Main content (hero section — may be the largest single section)
- **Section 4-N**: Remaining phases, outputs, etc.

Each section should be independently understandable: its elements, internal arrows, and any cross-references to adjacent sections.

### What NOT to Do

- **Don't generate the entire diagram in one response.** You will hit the output token limit and produce truncated, broken JSON. Even if the diagram is small enough to fit, splitting into sections produces better results.
- **Don't use a coding agent** to generate the JSON. The agent won't have sufficient context about the skill's rules, and the coordination overhead negates any benefit.
- **Don't write a Python generator script.** The templating and coordinate math seem helpful but introduce a layer of indirection that makes debugging harder. Hand-crafted JSON with descriptive IDs is more maintainable.

---

## Visual Pattern Library

### Fan-Out (One-to-Many)
Central element with arrows radiating to multiple targets. Use for: sources, PRDs, root causes, central hubs.
```
        ○
       ↗
  □ → ○
       ↘
        ○
```

### Convergence (Many-to-One)
Multiple inputs merging through arrows to single output. Use for: aggregation, funnels, synthesis.
```
  ○ ↘
  ○ → □
  ○ ↗
```

### Tree (Hierarchy)
Parent-child branching with connecting lines and free-floating text (no boxes needed). Use for: file systems, org charts, taxonomies.
```
  label
  ├── label
  │   ├── label
  │   └── label
  └── label
```
Use `line` elements for the trunk and branches, free-floating text for labels.

### Spiral/Cycle (Continuous Loop)
Elements in sequence with arrow returning to start. Use for: feedback loops, iterative processes, evolution.
```
  □ → □
  ↑     ↓
  □ ← □
```

### Cloud (Abstract State)
Overlapping ellipses with varied sizes. Use for: context, memory, conversations, mental states.

### Assembly Line (Transformation)
Input → Process Box → Output with clear before/after. Use for: transformations, processing, conversion.
```
  ○○○ → [PROCESS] → □□□
  chaos              order
```

### Side-by-Side (Comparison)
Two parallel structures with visual contrast. Use for: before/after, options, trade-offs.

### Gap/Break (Separation)
Visual whitespace or barrier between sections. Use for: phase changes, context resets, boundaries.

### Grouping Frames (Lightweight Containment)
Large, low-opacity rectangles that sit behind a cluster of elements to show they belong together — without heavy borders or saturated fills. Use for: swim lanes, pipeline stages, system boundaries, "belongs to" regions.
- `opacity: 15-25` (barely visible tint)
- `strokeWidth: 0` or `1` with a light color
- `roundness: {"type": 3}` for soft edges
- Place them **before** content elements in the JSON so they render behind

```
  ┌─────────────────────────┐  ← opacity: 20, light fill
  │  □ → □ → □              │
  │  Component A  Region    │
  └─────────────────────────┘
```

This replaces heavy swimlane borders and saturated background fills. The content stays visually dominant while the frame provides grouping context.

### Lines as Structure
Use lines (type: `line`, not arrows) as primary structural elements instead of boxes:
- **Timelines**: Vertical or horizontal line with small dots (10-20px ellipses) at intervals, free-floating labels beside each dot
- **Tree structures**: Vertical trunk line + horizontal branch lines, with free-floating text labels (no boxes needed)
- **Dividers**: Thin dashed lines to separate sections
- **Flow spines**: A central line that elements relate to, rather than connecting boxes

```
Timeline:           Tree:
  ●─── Label 1        │
  │                   ├── item
  ●─── Label 2        │   ├── sub
  │                   │   └── sub
  ●─── Label 3        └── item
```

Lines + free-floating text often creates a cleaner result than boxes + contained text.

---

## Shape Meaning

Choose shape based on what it represents—or use no shape at all:

| Concept Type | Shape | Why |
|--------------|-------|-----|
| Labels, descriptions, details | **none** (free-floating text) | Typography creates hierarchy |
| Section titles, annotations | **none** (free-floating text) | Font size/weight is enough |
| Markers on a timeline | small `ellipse` (10-20px) | Visual anchor, not container |
| Start, trigger, input | `ellipse` | Soft, origin-like |
| End, output, result | `ellipse` | Completion, destination |
| Decision, condition | `diamond` | Classic decision symbol |
| Process, action, step | `rectangle` | Contained action |
| Abstract state, context | overlapping `ellipse` | Fuzzy, cloud-like |
| Hierarchy node | lines + text (no boxes) | Structure through lines |

**Rule**: Default to no container. Add shapes only when they carry meaning. Aim for <30% of text elements to be inside containers.

**Diamond caution**: Diamonds have poor text fitting — text clips or requires disproportionate sizing. For decisions/conditions, prefer a **rectangle with Decision semantic color** (`fill: #fef3c7`, `stroke: #b45309`) as an alternative. Reserve diamonds for small single-word labels like "Yes/No" or when the diamond shape is specifically meaningful.

---

## Color as Meaning

Colors encode information, not decoration. Every color choice should come from `references/color-palette.md` — the semantic shape colors, text hierarchy colors, and evidence artifact colors are all defined there.

**Key principles:**
- Each semantic purpose (start, end, decision, AI, error, etc.) has a specific fill/stroke pair
- Free-floating text uses color for hierarchy (titles, subtitles, details — each at a different level)
- Evidence artifacts (code snippets, JSON examples) use their own dark background + colored text scheme
- Always pair a darker stroke with a lighter fill for contrast

**Do not invent new colors.** If a concept doesn't fit an existing semantic category, use Primary/Neutral or Secondary.

---

## Arrow Styling

Arrows connect elements but should not compete with them visually. Keep them subtle and consistent.

**Elbowed auto-routing (mandatory)**: Always use `"elbowed": true` on arrow elements. This enables Excalidraw's built-in orthogonal pathfinding — arrows automatically route with clean 90-degree bends between bound elements. Combine with `"roundness": {"type": 2}` for smooth rounded corners at the bends, and `"roughness": 1` for hand-drawn style (matching shapes). You only need 2 points in the `points` array (start and end) — Excalidraw calculates the full path automatically. **Never manually compute waypoints** — let the elbowed routing handle it.

**IMPORTANT: Static export limitation**: The `exportToSvg` renderer used by the render script does NOT run elbowed pathfinding — it renders the `points` array literally. This means:
- For **horizontal or vertical** arrows (no bends needed): 2 points work fine in both editor and static export
- For **arrows that need bends** (source and target not aligned on the same axis): you MUST provide L-shaped waypoints (3+ points) so the static render looks correct. **A direct diagonal line `[[0,0], [dx, dy]]` is NEVER acceptable** — it produces arrows that hit boxes at an angle instead of perpendicular. The elbowed routing in the editor will override these waypoints when the file is opened interactively, but the manual waypoints ensure the static PNG renders correctly too
- **L-shape pattern**: `[[0,0], [dx, 0], [dx, dy]]` (horizontal first, then vertical) or `[[0,0], [0, dy], [dx, dy]]` (vertical first, then horizontal) — choose whichever matches the exit edge direction. The `roundness: type 2` smooths the corner

**Perpendicular connections (mandatory)**: Arrows must ALWAYS exit and enter boxes perpendicular to the box edge — never at a diagonal. This means:
- `fixedPoint` must be at the **center of an edge**: `[0.5, -0.15]` (top), `[1.15, 0.5]` (right), `[0.5, 1.15]` (bottom), `[-0.15, 0.5]` (left). Never use corner values like `[1.15, -0.15]` or `[1.15, 1.15]`.
- When source and target are not aligned (different x AND different y), the `points` array MUST use L-shaped waypoints — never a direct diagonal line between them. Use `[[0,0], [dx, 0], [dx, dy]]` (horizontal-then-vertical) or `[[0,0], [0, dy], [dx, dy]]` (vertical-then-horizontal).
- Choose the edge (`fixedPoint`) that faces toward the target element. For left-to-right flow, exit from the right edge and enter the left edge. For top-to-bottom flow, exit from the bottom and enter the top.

**Direct path routing (mandatory)**: Arrows must take the shortest orthogonal path between connected elements — never loop around, over, or behind boxes. Specifically:
- For a **top-to-bottom flow**, the arrow exits the bottom of box A and enters the top of box B. It must go **downward only** — never route upward above box A and then back down.
- For a **left-to-right flow**, the arrow exits the right of box A and enters the left of box B. It must go **rightward only** — never route leftward behind box A and then back right.
- If the elbowed auto-router produces a looping/backtracking path (common when boxes are close together or slightly offset), **override it with explicit waypoints** in the `points` array that take the direct route.
- **The arrow's `points` array should never contain coordinates that go in the opposite direction of the flow.** For a downward arrow, no y-coordinate in `points` should be negative (above the start). For a rightward arrow, no x-coordinate should be negative (left of the start).
- When two elements are vertically stacked, use `fixedPoint: [0.5, 1.15]` (bottom center) on the source and `fixedPoint: [0.5, -0.15]` (top center) on the target, with `points: [[0, 0], [0, dy]]` — a straight vertical line, no bends needed.

**Color**: Default to neutral dark gray (`#374151`) for all arrows. Only use a semantic color (from the palette) when the arrow color itself carries meaning — e.g., green for success path, red for error path. A rainbow of differently-colored arrows is visual noise.

**Width**: Use `strokeWidth: 1` for most arrows. Use `strokeWidth: 2` only for the primary/critical flow path to make it stand out.

**Style**: Use `strokeStyle: "solid"` (default) for primary flows. Use `strokeStyle: "dashed"` for optional, async, or secondary paths.

**Arrowheads**: Use `"endArrowhead": "triangle"` for a visible filled arrowhead. Avoid `"bar"` (too thin to see in static renders) and `"arrow"` (open chevron, less clean). Use `null` start arrowhead unless showing bidirectional communication.

### Group Related Elements Before Connecting Arrows

**When multiple small elements share the same downstream connection, group them into a container and connect the arrow from the container — not from each individual element.**

Bad: 10 individual source boxes each with their own arrow to a target → spaghetti.
Good: 10 source boxes inside a grouping frame, one arrow from the frame to the target → clean.

```
BAD (spaghetti):              GOOD (grouped):
  □ ──→                        ┌─────────────┐
  □ ──→  ○                     │ □ □ □ □ □ □ │──→ ○
  □ ──→                        └─────────────┘
```

To implement grouping for arrow purposes:
1. Create a container rectangle (grouping frame or visible border) around the related elements
2. Bind the arrow's `startBinding` or `endBinding` to the **container's** `elementId`, not to any individual child element
3. Add the arrow to the container's `boundElements` array
4. Position the arrow to exit from the container's edge (right side for left-to-right flow)

This avoids the common problem of N arrows fanning out from N small boxes, creating visual clutter. One arrow from the group is cleaner and communicates the same thing: "all of these feed into that."

### Arrows Must Touch Elements (Binding)

**Arrows must visually connect to the elements they link, but with clear spacing — never touching or overlapping the box border.** To achieve this:

1. **Always set `startBinding` and `endBinding`** with the correct `elementId`, **`fixedPoint`** for edge position, and **`gap: 0`**. The `fixedPoint` is a normalized `[x, y]` coordinate on the element (0-1 range, where values slightly outside create a gap). Use `0.15` offset for visible spacing. Common values: `[1.15, 0.5]` = right edge center, `[-0.15, 0.5]` = left edge center, `[0.5, 1.15]` = bottom center, `[0.5, -0.15]` = top center. This format is required for elbowed arrows — the editor strips bindings without `fixedPoint`.
**Multiple arrows landing on the same box**: When two or more arrows connect to the same target element, they should all use the **same `fixedPoint`** value (e.g., all use `[-0.10, 0.5]` for left edge center). Do NOT spread them to different points — the elbowed routing handles separation automatically.
2. **The bound element must list the arrow in its `boundElements` array.** Both sides of the binding must be consistent.
3. **Position the arrow's `x`/`y` at the edge of the source element**, not at its center. The `points` array defines the arrow path relative to `x`/`y`.
4. **For vertical arrows**: set `x` to the horizontal center of the source element, `y` to its bottom edge (y + height). The endpoint `points[1]` should reach the top edge of the target.
5. **For horizontal arrows**: set `y` to the vertical center of the source, `x` to its right edge (x + width). The endpoint should reach the left edge of the target.

**Test**: After rendering, every arrow should appear to start from one element's border and end at another's — no visible gaps.

**No arrows into empty space (mandatory)**: Every arrow must visually connect to a target element in the static PNG render — not just via bindings. Because the static renderer ignores elbowed pathfinding and draws `points` literally, you MUST ensure the final point in the `points` array actually reaches the target element's edge. If source and target are far apart or on different Y/X levels, use Z-shaped waypoints (e.g., `[[0,0],[dx/2,0],[dx/2,dy],[dx,dy]]`) so the rendered path travels to the target instead of ending in empty space. **After every render, visually verify that no arrowhead points into a void.**

---

## Modern Aesthetics

For clean, professional diagrams:

### Roughness
- `roughness: 1` — Hand-drawn, organic feel. **This is the default.** Gives diagrams a natural, approachable look.
- `roughness: 0` — Clean, crisp edges. Use only when the user explicitly requests a sterile/technical style.
- `roughness: 2` — Very sketchy, childlike scribbles. Avoid — too messy for professional use.

**Default to 1** for all elements (shapes, lines, arrows). The slight hand-drawn wobble makes diagrams feel more human and less like auto-generated output.

### Stroke Width
- `strokeWidth: 1` — Thin, elegant. Good for lines, dividers, subtle connections.
- `strokeWidth: 2` — Standard. Good for shapes and primary arrows.
- `strokeWidth: 3` — Bold. Use sparingly for emphasis (main flow line, key connections).

### Opacity
**Use `opacity: 100` for all content elements** (shapes, text, arrows). Use color, size, and stroke width to create hierarchy instead of transparency.

**Exception — Grouping Frames**: Use low-opacity rectangles (`opacity: 15-25`) as lightweight visual containers to show which elements belong together. These are *layout aids*, not content — they should have no stroke or a very faint one, and sit behind the elements they group. See the **Grouping Frames** pattern below and the template in `references/element-templates.md`.

### Small Markers Instead of Shapes
Instead of full shapes, use small dots (10-20px ellipses) as:
- Timeline markers
- Bullet points
- Connection nodes
- Visual anchors for free-floating text

---

## Layout Principles

### Hierarchy Through Scale
- **Hero**: 300×150 - visual anchor, most important
- **Primary**: 180×90
- **Secondary**: 120×60
- **Small**: 60×40

### Whitespace = Importance
The most important element has the most empty space around it (200px+).

### Flow Direction
Guide the eye: typically left→right or top→bottom for sequences, radial for hub-and-spoke.

### Centering & Balance
The diagram should feel centered on the canvas — not clustered in one corner with empty space elsewhere. After placing all elements:
- Calculate the bounding box of all content (min/max x and y)
- The content should be roughly centered horizontally within the canvas
- Avoid large empty voids on one side while the other is dense
- If the diagram has a "legend" or annotation block, position it to fill otherwise-empty space (e.g., bottom-right)

### Connections Required
Position alone doesn't show relationships. If A relates to B, there must be an arrow.

### Canvas Aspect Ratio
Consider how the diagram will be viewed:
- **Presentation/slides**: Target 16:9 (~1920x1080). Keep content within this frame.
- **Documentation/wiki**: Width up to ~1900px is fine; height can extend freely for scrolling.
- **Both**: Design for 16:9 width but allow vertical overflow — this works in both contexts.

Avoid extremely wide diagrams (>2500px) that require horizontal scrolling, or extremely narrow ones (<800px) that waste screen space.

### Minimum Spacing Constants
Consistent spacing prevents the cramped look that requires post-hoc rework. Use these minimums:

| Between | Min Gap | Notes |
|---------|---------|-------|
| Sibling elements (same level) | **10px** | Elements in a row/column at the same hierarchy |
| Parent container and child content | **15px** | Padding inside a grouping frame or container |
| Sequential steps (vertical flow) | **12px** | Arrow + gap between connected elements |
| Major sections/regions | **40px** | Between swim lanes, pipeline stages, etc. |
| Lane backgrounds | **20px** | Gap between adjacent grouping frames |
| Element and its floating annotation | **5px** | Keep annotations visually anchored |
| Diagram title and first content | **30px** | Breathing room below the title |

---

## Text Rules

**CRITICAL**: The JSON `text` property contains ONLY readable words.

```json
{
  "id": "myElement1",
  "text": "Start",
  "originalText": "Start"
}
```

Settings: `fontFamily: 3`, `textAlign: "center"`, `verticalAlign: "middle"`

### Font Size Tiers

Use a strict 4-tier system. **Do not use more than 4 font sizes per diagram** — mixing arbitrary sizes creates visual chaos.

| Tier | Size | Use For | Example |
|------|------|---------|---------|
| **XL** | `28px` | Diagram title (one per diagram) | "CURRENT INGESTION ARCHITECTURE" |
| **L** | `18-20px` | Section headings, lane titles | "BATCH INGESTION PATH" |
| **M** | `13-14px` | Component labels inside shapes, subtitles | "Lambda: Unpack 0165" |
| **S** | `10-11px` | Details, annotations, evidence artifact text | "Retry: 3 attempts, 20s backoff" |

Pick one specific size per tier at the start of a diagram (e.g., XL=28, L=18, M=13, S=10) and use those four sizes consistently throughout.

### Text Must Fit Inside Shapes

When text is bound to a container (`containerId`), the container **must be wide and tall enough** for the text at its font size. Excalidraw does not auto-wrap or auto-resize in raw JSON — if the container is too small, text will overflow and clip.

**Sizing rule of thumb** (monospace, `fontFamily: 3`):
- Each character is roughly `fontSize × 0.6` pixels wide
- Each line is roughly `fontSize × 1.25` pixels tall
- Add 20px horizontal padding and 10px vertical padding

**Example**: "Validation + business logic" at `fontSize: 13` = 28 chars × 7.8px = ~218px text width. Container needs at least **238px** width (218 + 20 padding).

**Always overestimate container size.** A slightly too-wide box is invisible; clipped text is a visible defect.

---

## JSON Structure

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [...],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": 20
  },
  "files": {}
}
```

## Element Templates

See `references/element-templates.md` for copy-paste JSON templates for each element type (text, line, dot, rectangle, arrow). Pull colors from `references/color-palette.md` based on each element's semantic purpose.

---

## Render & Validate (MANDATORY)

You cannot judge a diagram from JSON alone. After generating or editing the Excalidraw JSON, you MUST render it to PNG, view the image, and fix what you see — in a loop until it's right. This is a core part of the workflow, not a final check.

### How to Render

```bash
cd "${CLAUDE_PLUGIN_ROOT}/skills/excalidraw-diagram/references" && uv run python render_excalidraw.py <path-to-file.excalidraw>
```

This outputs a PNG next to the `.excalidraw` file. Then use the **Read tool** on the PNG to actually view it.

### The Loop

After generating the initial JSON, run this cycle:

**1. Render & View** — Run the render script, then Read the PNG.

**2. Audit against your original vision** — Before looking for bugs, compare the rendered result to what you designed in Steps 1-4. Ask:
- Does the visual structure match the conceptual structure you planned?
- Does each section use the pattern you intended (fan-out, convergence, timeline, etc.)?
- Does the eye flow through the diagram in the order you designed?
- Is the visual hierarchy correct — hero elements dominant, supporting elements smaller?
- For technical diagrams: are the evidence artifacts (code snippets, data examples) readable and properly placed?

**3. Check for visual defects:**
- Text clipped by or overflowing its container
- Text or shapes overlapping other elements
- Arrows crossing through elements instead of routing around them
- Arrows landing on the wrong element or pointing into empty space
- Labels floating ambiguously (not clearly anchored to what they describe)
- Uneven spacing between elements that should be evenly spaced
- Sections with too much whitespace next to sections that are too cramped
- Text too small to read at the rendered size
- Overall composition feels lopsided or unbalanced

**4. Fix** — Edit the JSON to address everything you found. Common fixes:
- Widen containers when text is clipped
- Adjust `x`/`y` coordinates to fix spacing and alignment
- Add intermediate waypoints to arrow `points` arrays to route around elements
- Reposition labels closer to the element they describe
- Resize elements to rebalance visual weight across sections

**5. Re-render & re-view** — Run the render script again and Read the new PNG.

**6. Repeat** — Keep cycling until the diagram passes both the vision check (Step 2) and the defect check (Step 3). Typically takes 2-4 iterations. Don't stop after one pass just because there are no critical bugs — if the composition could be better, improve it.

### When to Stop

The loop is done when:
- The rendered diagram matches the conceptual design from your planning steps
- No text is clipped, overlapping, or unreadable
- Arrows route cleanly and connect to the right elements
- Spacing is consistent and the composition is balanced
- You'd be comfortable showing it to someone without caveats

### First-Time Setup
If the render script hasn't been set up yet:
```bash
cd "${CLAUDE_PLUGIN_ROOT}/skills/excalidraw-diagram/references"
uv sync
uv run playwright install chromium
```

### Export for Sharing
When exporting diagrams for others (documentation, presentations, PRs):
- Keep the `.excalidraw` source file alongside the PNG — it preserves full editability
- If sharing only the PNG, note that the source is lost unless you re-export from the `.excalidraw` file
- For presentation use, export at 2x scale for crisp rendering on high-DPI screens

---

## Quality Checklist

### Depth & Evidence (Check First for Technical Diagrams)
1. **Research done**: Did you look up actual specs, formats, event names?
2. **Evidence artifacts**: Are there code snippets, JSON examples, or real data?
3. **Multi-zoom**: Does it have summary flow + section boundaries + detail?
4. **Concrete over abstract**: Real content shown, not just labeled boxes?
5. **Educational value**: Could someone learn something concrete from this?

### Conceptual
6. **Isomorphism**: Does each visual structure mirror its concept's behavior?
7. **Argument**: Does the diagram SHOW something text alone couldn't?
8. **Variety**: Does each major concept use a different visual pattern?
9. **No uniform containers**: Avoided card grids and equal boxes?

### Container Discipline
10. **Minimal containers**: Could any boxed element work as free-floating text instead?
11. **Lines as structure**: Are tree/timeline patterns using lines + text rather than boxes?
12. **Typography hierarchy**: Are font size and color creating visual hierarchy (reducing need for boxes)?

### Structural
13. **Connections**: Every relationship has an arrow or line
14. **Flow**: Clear visual path for the eye to follow
15. **Hierarchy**: Important elements are larger/more isolated

### Technical
16. **Text clean**: `text` contains only readable words
17. **Font**: `fontFamily: 3`
18. **Font tiers**: At most 4 font sizes used (XL/L/M/S), consistent throughout
19. **Roughness**: `roughness: 1` (hand-drawn default) for all elements, unless user requests clean/sterile style
20. **Opacity**: `opacity: 100` for content elements; `opacity: 15-25` only for grouping frames
21. **Arrows**: Neutral color by default; colored only when distinction carries meaning
22. **Container ratio**: <30% of text elements should be inside containers

### Visual Validation (Render Required)
21. **Rendered to PNG**: Diagram has been rendered and visually inspected
22. **No text overflow**: All text fits within its container
23. **No overlapping elements**: Shapes and text don't overlap unintentionally
24. **Even spacing**: Similar elements have consistent spacing
25. **Minimum gaps**: Spacing meets the minimum constants (10px siblings, 40px sections, etc.)
26. **Arrows land correctly**: Arrows connect to intended elements without crossing others
26. **Readable at export size**: Text is legible in the rendered PNG
27. **Balanced composition**: No large empty voids or overcrowded regions
