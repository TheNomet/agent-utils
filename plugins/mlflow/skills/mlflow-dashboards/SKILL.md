---
name: mlflow-dashboards
description: Create MLflow Traces "saved views" (the Views dropdown) programmatically, since there is no Python/REST API — they are experiment tags. Use ONLY when the user explicitly wants to create, script, automate, or debug saved views / dashboards for the MLflow Traces tab (e.g. "give each experiment a Runs and an Eval view", "create the saved views on deploy", "my saved-view filter fails"). Do NOT use for general MLflow tracing/eval/versioning setup — that is the mlflow-observability skill. Skip entirely if the user hasn't asked for saved views; auto-creating views mutates their experiment tags, which they may not want.
---

# MLflow Traces saved views (dashboards)

The Traces tab has a **Views** dropdown ("Save current view"). There is **no
Python/REST API** for it — a saved view is persisted as an **experiment tag**.
You can create views automatically by writing that tag yourself (schema verified
against MLflow source `TracesV3SavedViews.tsx`).

> **Only do this when asked.** Writing these tags mutates the user's experiment
> and makes views appear in their UI. If they haven't explicitly asked for saved
> views/dashboards, don't create them.

A common ask: give every experiment two views — one for ad-hoc **Runs**, one for
**Eval** traces — and (re)create them as part of the deploy step.

## Tag format (exact)

- **Key:** `mlflow.traceViewState.<id>` (id = any stable string, e.g. a uuid).
  The runs table uses a *different* prefix, `mlflow.sharedViewState.` — don't
  confuse them; the Traces dropdown only reads `mlflow.traceViewState.`.
- **Value:** a JSON envelope `{"name", "createdAt", "state"}` where `createdAt`
  is epoch **ms** and `state` is `json.dumps(CapturedTraceViewState)`. `state`
  may be deflate-compressed (`deflate;<b64>`) OR plain JSON — the decoder accepts
  both, so **write plain JSON**.
- **CapturedTraceViewState:**
  ```json
  {"single": {"selectedColumns": "col1,col2", "sort": "request_time::TRACE_INFO::false"},
   "multi":  {"filter": ["trace_name::=::x_eval::trace_name"]}}
  ```
  - `selectedColumns` = comma-joined column **ids**.
  - `sort` = `key::type::asc` where `type` is a `TracesTableColumnType` enum
    literal — **`TRACE_INFO`**, `ASSESSMENT`, `EXPECTATION`, `INPUT` (case
    matters; `trace_info` silently won't apply).
  - each `filter` = `column::operator::value::key`; the operator is compiled
    **straight into the backend SQL**, so it must be valid there for that column.
    Do NOT quote the value — the UI wraps it in quotes when building the query.
- **Value length is capped at 5000 chars** server-side — a longer write
  *hard-throws* in the tracking store. Keep views lean.

## Column ids (the non-obvious ones)

Info columns are plain: `request`, `response`, `trace_name`, `tokens`,
`execution_duration`, `request_time`, `state`, `source`, `git_commit`, `prompt`,
`session`, `user`, `run_name`. Custom trace tags (e.g. `agent_version`) are
usable as column ids too.

> **GOTCHA — assessment columns are suffixed.** An assessment/scorer column id is
> **`<name>_assessment_column`**, not the bare scorer name. So
> `answer_correctness` → `answer_correctness_assessment_column`. Using the bare
> name silently shows no column.

## Write it

```python
import json, time, uuid, mlflow
client = mlflow.MlflowClient()

def save_view(experiment_id, name, columns, filters=None):
    state = {"single": {"selectedColumns": ",".join(columns),
                        "sort": "request_time::TRACE_INFO::false"}}
    if filters:
        state["multi"] = {"filter": filters}
    envelope = json.dumps({"name": name, "createdAt": int(time.time()*1000),
                           "state": json.dumps(state)})
    client.set_experiment_tag(experiment_id, f"mlflow.traceViewState.{uuid.uuid4().hex}", envelope)
```

Make it **idempotent by name**: saved-view ids are random, so to "update" a view
delete any existing `mlflow.traceViewState.*` tag whose decoded `name` matches,
then write a fresh one. Wire it into a deploy step so `deploy <exp>` always
(re)creates the views — the "dashboards automatically" outcome.

A sensible split for an agent (partitions on a distinct eval-trace name):
- **Runs view:** `request, response, <llm_judge>_assessment_column, trace_name,
  tokens, execution_duration, git_commit, prompt, agent_version, state`; filter
  OUT eval traces (`trace_name::!=::<profile>_eval::trace_name`). Include only the
  LLM-judge assessment(s) that run inline on ad-hoc runs — NOT the deterministic
  scorers, which need ground truth and only run in batch eval, so they'd be empty
  on run traces.
- **Eval view:** `request, response, <scorer>_assessment_column..., state`; filter
  TO eval traces (`trace_name::=::<profile>_eval::trace_name`). Include every
  scorer + judge column.
- This depends on giving eval traces a distinct name (e.g. tag
  `mlflow.traceName = "<profile>_eval"`) so the two views can partition cleanly.

> **GOTCHA — trace_name filters only accept `=` / `!=`.** A `trace_name` filter
> compiles to `attributes.name <operator> '<value>'` and the operator is passed
> **straight into the backend SQL**. `CONTAINS` (which the filter *popover*
> offers) is NOT valid SQL there and the query fails with `Invalid clause(s) in
> filter string`. Use `=` against the exact trace name (or `!=` to exclude). Only
> some columns support `CONTAINS` server-side (e.g. `session`, `span.name`,
> `span.type`, `span.content` compile to `ILIKE '%...%'`); most trace-info
> columns don't.

> **Note — opening a view shows a "shared view" banner.** MLflow applies a saved
> view via the URL, which it treats as a read-only "shared view" overlay
> ("Override my view" / "Discard shared view"). This is normal for ANY opened
> saved view (UI-created or programmatic), not a bug. There's no way to set a
> personal default view via a tag — that's local/URL state.
