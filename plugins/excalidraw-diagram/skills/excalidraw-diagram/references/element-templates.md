# Element Templates

Copy-paste JSON templates for each Excalidraw element type. The `strokeColor` and `backgroundColor` values are placeholders — always pull actual colors from `color-palette.md` based on the element's semantic purpose.

## Free-Floating Text (no container)
```json
{
  "type": "text",
  "id": "label1",
  "x": 100, "y": 100,
  "width": 200, "height": 25,
  "text": "Section Title",
  "originalText": "Section Title",
  "fontSize": 20,
  "fontFamily": 3,
  "textAlign": "left",
  "verticalAlign": "top",
  "strokeColor": "<title color from palette>",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "angle": 0,
  "seed": 11111,
  "version": 1,
  "versionNonce": 22222,
  "isDeleted": false,
  "groupIds": [],
  "boundElements": null,
  "link": null,
  "locked": false,
  "containerId": null,
  "lineHeight": 1.25
}
```

## Line (structural, not arrow)
```json
{
  "type": "line",
  "id": "line1",
  "x": 100, "y": 100,
  "width": 0, "height": 200,
  "strokeColor": "<structural line color from palette>",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "angle": 0,
  "seed": 44444,
  "version": 1,
  "versionNonce": 55555,
  "isDeleted": false,
  "groupIds": [],
  "boundElements": null,
  "link": null,
  "locked": false,
  "points": [[0, 0], [0, 200]]
}
```

## Grouping Frame (low-opacity container)
```json
{
  "type": "rectangle",
  "id": "frame1",
  "x": 10, "y": 80,
  "width": 920, "height": 800,
  "strokeColor": "#1e3a5f",
  "backgroundColor": "#dbeafe",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 20,
  "angle": 0,
  "seed": 88888,
  "version": 1,
  "versionNonce": 88889,
  "isDeleted": false,
  "groupIds": [],
  "boundElements": [],
  "link": null,
  "locked": false,
  "roundness": {"type": 3}
}
```

Place grouping frames **before** the elements they contain in the JSON array so they render behind. Use `opacity: 15-25` — just enough tint to see the boundary without competing with content. Choose a fill from the palette that matches the region's semantic meaning (e.g., `#dbeafe` blue for a batch path, `#ecfdf5` green for an event path).

## Small Marker Dot
```json
{
  "type": "ellipse",
  "id": "dot1",
  "x": 94, "y": 94,
  "width": 12, "height": 12,
  "strokeColor": "<marker dot color from palette>",
  "backgroundColor": "<marker dot color from palette>",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "angle": 0,
  "seed": 66666,
  "version": 1,
  "versionNonce": 77777,
  "isDeleted": false,
  "groupIds": [],
  "boundElements": null,
  "link": null,
  "locked": false
}
```

## Rectangle
```json
{
  "type": "rectangle",
  "id": "elem1",
  "x": 100, "y": 100, "width": 180, "height": 90,
  "strokeColor": "<stroke from palette based on semantic purpose>",
  "backgroundColor": "<fill from palette based on semantic purpose>",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "angle": 0,
  "seed": 12345,
  "version": 1,
  "versionNonce": 67890,
  "isDeleted": false,
  "groupIds": [],
  "boundElements": [{"id": "text1", "type": "text"}],
  "link": null,
  "locked": false,
  "roundness": {"type": 3}
}
```

## Text (centered in shape)
```json
{
  "type": "text",
  "id": "text1",
  "x": 130, "y": 132,
  "width": 120, "height": 25,
  "text": "Process",
  "originalText": "Process",
  "fontSize": 16,
  "fontFamily": 3,
  "textAlign": "center",
  "verticalAlign": "middle",
  "strokeColor": "<text color — match parent shape's stroke or use 'on light/dark fills' from palette>",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "angle": 0,
  "seed": 11111,
  "version": 1,
  "versionNonce": 22222,
  "isDeleted": false,
  "groupIds": [],
  "boundElements": null,
  "link": null,
  "locked": false,
  "containerId": "elem1",
  "lineHeight": 1.25
}
```

## Arrow
```json
{
  "type": "arrow",
  "id": "arrow1",
  "x": 282, "y": 145, "width": 118, "height": 0,
  "strokeColor": "#374151",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "angle": 0,
  "seed": 33333,
  "version": 1,
  "versionNonce": 44444,
  "isDeleted": false,
  "groupIds": [],
  "boundElements": null,
  "link": null,
  "locked": false,
  "roundness": {"type": 2},
  "elbowed": true,
  "points": [[0, 0], [118, 0]],
  "startBinding": {"elementId": "elem1", "fixedPoint": [1.15, 0.5], "focus": 0, "gap": 0},
  "endBinding": {"elementId": "elem2", "fixedPoint": [-0.15, 0.5], "focus": 0, "gap": 0},
  "startArrowhead": null,
  "endArrowhead": "triangle"
}
```

- **Always include `"elbowed": true`** for automatic orthogonal routing. Excalidraw calculates the path with 90-degree bends between bound elements — no manual waypoints needed.
- **Combine with `"roundness": {"type": 2}`** for smooth rounded corners at the bends (not sharp 90-degree angles).
- **Use `"roughness": 1`** for hand-drawn style matching the rest of the diagram. Elbowed arrows work with any roughness value.
- **Only 2 points needed for straight (aligned) arrows**: Just specify start `[0,0]` and approximate end position. Excalidraw auto-routes the full path based on the element bindings.
- **L-shaped points required for non-aligned arrows**: When source and target differ on both axes, NEVER use a direct diagonal `[[0,0], [dx, dy]]`. Use `[[0,0], [dx, 0], [dx, dy]]` (horizontal-then-vertical) or `[[0,0], [0, dy], [dx, dy]]` (vertical-then-horizontal). This ensures the arrow stays perpendicular to both boxes in the static render.
- Use `"triangle"` for a visible filled arrowhead. Avoid `"bar"` (too thin in static renders) and `"arrow"` (open chevron).
- Set `gap: 0` and use `fixedPoint` to control edge position and spacing. Use `0.15` offset outside the 0-1 range for visible gap. **fixedPoint must always be at an edge center** — never at corners. Common fixedPoints: `[1.15, 0.5]` right edge, `[-0.15, 0.5]` left edge, `[0.5, 1.15]` bottom, `[0.5, -0.15]` top. This ensures arrows are always perpendicular to the box.
- **Multiple arrows to same box**: All arrows landing on the same target must use the **same `fixedPoint`** — do not spread them to different points.
- Both `elem1` and `elem2` must include `{"id": "arrow1", "type": "arrow"}` in their `boundElements` array.
- **Group-to-target**: When multiple sources share a destination, bind the arrow to a grouping container — not to each individual element.
