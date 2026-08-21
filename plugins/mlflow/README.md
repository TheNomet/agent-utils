# mlflow

MLflow for GenAI agent observability: make every agent run traceable, gradable, and attributable to a specific prompt + agent version + commit — then surface it all in the Traces tab.

## Contents

- `skills/mlflow-observability/SKILL.md` — server setup, tracing/autolog, WHO/WHAT/WHICH attribution, deterministic scorers + LLM judges, batch vs. inline eval, prompt registry, and agent versioning. Framework-agnostic (Strands, LangGraph, LangChain, or plain).
- `skills/mlflow-dashboards/SKILL.md` — create the Traces "Views" dropdown (saved views) programmatically by writing experiment tags, since there's no Python/REST API for it. Use only when explicitly asked, since it mutates the user's experiment.

## Install

```
/plugin install mlflow@agent-utils
```
