---
name: mlflow-observability
description: Set up MLflow for GenAI agent observability — traceable runs, judges + evaluation, and agent versioning. Use when instrumenting an agent (Strands, LangGraph, LangChain, or plain) with MLflow tracing, building an evaluation pipeline with deterministic scorers and/or LLM judges, wiring a prompt registry, registering agent versions, or debugging why traces are missing metadata (empty Prompt/Version/Session columns), why an LLM judge hangs, or why the MLflow server stops accepting writes. For creating the Traces "saved views" dropdown from code, see the separate mlflow-dashboards skill. Covers the concrete code patterns and the non-obvious gotchas that make traces actually traceable.
---

# MLflow observability for GenAI agents

Make an agent **observable**: every run produces a trace you can attribute
(which prompt, which agent version, which commit), graded by judges that make
sense, with versions you can compare over time.

Three pillars, in order of dependency:

1. **Traceability** — capture the run + stamp WHO/WHAT/WHICH on the trace.
2. **Judges & evaluation** — grade runs meaningfully (deterministic first).
3. **Agent versioning** — snapshot the topology so results are attributable.

This skill is framework-agnostic; examples use the Anthropic-compatible gateway
pattern but apply to any provider.

---

## 0. Server setup (do this first, and get it right)

Run a tracking server backed by a **stable, explicit** store. Two hard rules:

```bash
mlflow server --host 127.0.0.1 --port 5050 \
  --backend-store-uri "sqlite:///$(pwd)/.mlflow/mlflow.db" \
  --artifacts-destination "$(pwd)/.mlflow/artifacts"
```

- **Pin ONE canonical backend path** and always start the server against it.
  Put it behind a `just mlflow` / Makefile target so it can't drift.
- **On macOS use port 5050**, not 5000 (AirPlay Receiver squats on 5000), and
  connect via `127.0.0.1`, not `localhost`.

> **GOTCHA — the silent write hang.** If the SQLite backend file is moved/renamed
> out from under a *running* server (e.g. you rename the dir that held it),
> **reads keep working but every write silently hangs** (`create_experiment`,
> trace export, `flush_trace_async_logging()` never returns) while a plain `curl`
> to the REST API looks fine. Symptom: agent runs finish and print output, but
> the process won't exit and traces never appear. Fix: kill the stale server
> (and its `huey`/job-runner children) and restart against the current path.
> Diagnose with `ps aux | grep mlflow` and check the `--backend-store-uri` the
> live process was started with.

Point the client at it once, per entry point:

```python
import mlflow
mlflow.set_tracking_uri("http://127.0.0.1:5050")
mlflow.set_experiment("my-agent")   # create/select the experiment
```

---

## 1. Traceability — capture + attribute every run

### Capture: autolog, don't hand-instrument

Turn on the framework's autolog once; it emits a span per model call and tool
call. Pick the one matching your framework — do NOT hand-wrap the agent in a
manual `start_span`, or the manual span becomes the trace root and hides the
real request/response.

```python
mlflow.langchain.autolog()   # LangChain / LangGraph
mlflow.strands.autolog()     # Strands
mlflow.openai.autolog()      # raw OpenAI SDK
```

> **GOTCHA — manual wrapper spans distort Request/Response.** A
> `with mlflow.start_span("my-agent"): ...` wrapper with no inputs/outputs shows
> up as an `UNKNOWN` root with `null` Request/Response in the Traces table. Let
> autolog own the root span; its inputs/outputs are the real ones. If you must
> add a root, set `span.set_inputs(...)`/`set_outputs(...)` on it.

### Attribute: stamp WHO / WHAT / WHICH on the trace

Autolog captures the computation; it does NOT record which prompt, which agent
version, or which git commit produced it. Stamp those explicitly after the run:

```python
trace_id = mlflow.get_last_active_trace_id()
client = mlflow.MlflowClient()

# Prompt column / "Linked prompts" tab:
client.link_prompt_versions_to_trace([prompt_version], trace_id)

# agent_version column (a tag — the trace's model link only shows the model NAME,
# not the version, so stamp the version explicitly):
client.set_trace_tag(trace_id, "agent_version", "v2")
```

Attach the trace to a **logged model** (the agent version, see §3) so the
Version column and `search_traces(model_id=...)` work:

```python
mlflow.set_active_model(model_id=agent_model_id)   # before the run
```

> **GOTCHA — Session is metadata, not a tag.** `client.set_trace_tag(tid,
> "mlflow.trace.session", ...)` does NOT populate the Session column. Session id
> is trace *metadata* and must be set with
> `mlflow.update_current_trace(session_id=...)` **while the trace is the active
> context** (inside the traced call). With some autolog integrations (LangChain
> under `genai.evaluate`) the autolog trace isn't the "current" trace, so you
> can't tag it after the fact — set it during the run or accept it's unset.

### OTel GenAI attributes (optional but nice)

For model/token attribution in the trace, set standard attributes:
`gen_ai.request.model`, `gen_ai.system`, `gen_ai.request.max_tokens`. Frameworks
that support `trace_attributes` (e.g. Strands' `Agent(trace_attributes=...)`)
will stamp them automatically.

### Gateway TLS (corporate proxies)

If the model routes through a gateway behind a corporate CA (Zscaler etc.),
export the CA so `httpx`/`requests` trust it, or the model call — and especially
the LLM judge's `requests.post` — silently retries and hangs:

```python
os.environ.setdefault("SSL_CERT_FILE", CA_BUNDLE)
os.environ.setdefault("REQUESTS_CA_BUNDLE", CA_BUNDLE)
```

---

## 2. Judges & evaluation — grade what matters

Two tiers. **Reach for deterministic scorers first**; use an LLM judge only for
genuinely subjective criteria.

### Tier 1 — deterministic code scorers (the real signal)

Anything verifiable (a number, a required tool call, a schema) should be graded
by code, not an LLM. These read the prediction's structured output, so they work
across frameworks:

```python
from mlflow.genai.scorers import scorer
from mlflow.entities import Feedback

@scorer
def answer_correctness(outputs, expectations) -> Feedback:
    expected = (expectations or {}).get("answer")
    got = extract_number(outputs["answer"])
    ok = expected is not None and abs(got - expected) < 1e-6
    return Feedback(value=ok, rationale=f"expected {expected}, got {got}")
```

MLflow OSS won't register arbitrary-code scorers — keep them version-controlled
in code and pass them to `evaluate()` inline.

### Tier 2 — LLM judge (subjective only)

Define judges as git-versioned specs (YAML) and build them for the gateway:

```python
from mlflow.genai.judges.instructions_judge import InstructionsJudge
InstructionsJudge(
    name="tool_use_adherence",
    instructions=spec["instructions"],
    model=f"anthropic:/{model_id}",
    base_url=f"{gateway}/v1/messages",   # gateway's messages endpoint
    generate_rationale_first=True,       # reason BEFORE the verdict — critical
    inference_params={"temperature": 0},
)
```

> **GOTCHA — LLM judges are fragile for verifiable properties.** With MLflow's
> default schema `[result, rationale]` the model commits its verdict *before*
> reasoning, then "corrects" itself with a SECOND JSON object, crashing the
> adapter's single-object `json.loads` (`Extra data`). Use `InstructionsJudge`
> (not `make_judge`, which drops the flag) with `generate_rationale_first=True`,
> `temperature=0`, and an instruction demanding exactly one JSON object. Even
> then, on a gateway that only treats the JSON schema as *advisory*, nothing
> constrains decoding.
>
> Also set `LITELLM_LOCAL_MODEL_COST_MAP=True` or litellm fetches a cost map from
> GitHub on first call and stalls behind the corporate proxy.

### Two modes: batch eval vs. inline per-trace

- **Batch evaluation** (graded, over a dataset with expectations):

  ```python
  os.environ.setdefault("MLFLOW_GENAI_EVAL_MAX_WORKERS", "1")  # see gotcha
  result = mlflow.genai.evaluate(
      data=dataset, predict_fn=predict, scorers=[*code_scorers, llm_judge]
  )
  ```

- **Inline per-trace** (a single ad-hoc run, "proof it works"): run the judge on
  one invocation and attach the verdict to that trace:

  ```python
  mlflow.log_feedback(trace_id=tid, name=fb.name, value=fb.value,
                      rationale=fb.rationale, source=fb.source)
  ```

  For an ad-hoc question there's no ground truth (do not run judges that expect one).

> **GOTCHA — async event loop + eval workers.** If the model uses one async HTTP
> client, running `predict_fn` across eval worker threads can bind the client to
> the wrong event loop and hang. Set `MLFLOW_GENAI_EVAL_MAX_WORKERS=1` and build a
> FRESH client per prediction.

> **GOTCHA — scorers read the prediction dict, not spans.** During evaluation the
> scored trace and the agent's autolog trace are often separate roots. Package
> everything a scorer needs (`{"answer", "tool_call_count", ...}`) into
> `predict_fn`'s return value; don't expect scorers to read tool spans.

> **GOTCHA — flush before you search.** Linking prompts/versions to "this run's
> traces" right after `evaluate()` races async trace export. Either
> `mlflow.flush_trace_async_logging()` first, or (more robust) capture each
> trace id via `get_last_active_trace_id()` inside `predict_fn` and reuse them.

### Prompt registry (git → registry)

Keep prompt text in a git file; register it and move an alias:

```python
pv = mlflow.genai.register_prompt(name="agent-system", template=text)
mlflow.genai.set_prompt_alias("agent-system", alias="production", version=pv.version)
# load by alias so behaviour changes without code edits:
prompt = mlflow.genai.load_prompt("prompts:/agent-system@production")
```

---

## 3. Agent versioning — snapshot the topology

An **agent version** is the full topology snapshot (prompt + model + git commit),
logged as an *external model* so runs and traces attribute to a configuration,
not just a model name.

```python
model = mlflow.create_external_model(name="my-agent", model_type="agent",
    params={"prompt_version": pv, "llm": model_id, "git_commit": sha,
            "version_number": n, "version_label": f"my-agent v{n}"},
    tags={"release_fingerprint": fingerprint, "version_number": str(n)})
mlflow.MlflowClient().link_prompt_version_to_model(
    name=prompt_name, version=pv, model_id=model.model_id)
```

Key patterns:

- **Fingerprint + "deploy if changed".** Hash `{prompt_version, llm, git_commit}`;
  register a new version only when the hash changes (a CI/CD gate). Idempotent
  re-runs are no-ops.
- **Resolve the version that matches the RUNNING model**, not merely the newest —
  otherwise a Sonnet run gets tagged with an Opus version. Search the agent's
  logged models newest-first; take the first whose `llm` param matches.
- **All versions share the model NAME** — the shared name *is* the version
  series; distinguish by the `version_label`/`llm` params.
- **Version number as a METRIC too.** MLflow run params only support `=`/`LIKE`;
  log `agent_version_number` as a metric so numeric filters
  (`metrics.agent_version_number > 1`) work.
- **`set_active_model` links traces; `log_inputs` links the eval RUN.**
  `set_active_model(model_id=...)` attaches traces + stamps model metrics, but the
  eval run→version link the Version column reads needs an explicit
  `client.log_inputs(run_id, models=[LoggedModelInput(model_id=...)])`.

### Comparing versions honestly

Don't read the Agent-version summary scalar (a lossy max/first aggregate that
hides regressions). Compare at the **eval-run** level: add the `agent_version` /
`llm` params as columns in the Evaluation runs table and Compare selected runs —
each run is one honest data point (dataset + metrics + timestamp).

---

## Dashboards / saved views

Creating the Traces "Views" dropdown entries (saved views) programmatically is a
separate concern — and one you should only do when explicitly asked, since it
mutates the user's experiment tags. See the **`mlflow-dashboards`** skill.
