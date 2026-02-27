# Brain OS

Brain OS is an AI-first personal and business operating system.
It converts natural-language intent into structured, auditable actions
executed against a Notion-based kernel.

This repository is the canonical system home for the Brain OS.

## Canonical Docs
- docs/intent.md — system intent
- docs/current_state.md — authoritative current behaviour
- docs/phases.md — phased roadmap
- docs/codex_rules.md — AI-first development rules
- docs/PHASE_EXECUTION_PROMPT.md — how Codex executes work

## Local Development
```bash
docker compose up
```

Compose now includes:
- `intent_normaliser`, `notion_gateway`, `voice_api`, `voice_web`
- `context_api` and `context_research_worker` for research retrieval + continuous ingestion

## Edge Dev
- `make dev`
- `http://brain-os.localhost`
- `docs/current_state.md` (authoritative)
- `docs/edge_integration.md`

