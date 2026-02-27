# Research Context Program — Phase Execution Prompts (1-6)

Use these prompts one phase at a time.  
Rules: follow truth hierarchy, avoid drift, and do not pre-implement future phases.

## Phase 1 Prompt
Implement only Phase 1:
- Repo: `intent_normaliser`
- Scope:
  - Add config-gated call to `context_api /v2/research/context/pack` in live `/v1/intents` flow.
  - Preserve idempotent intent behavior.
  - Include research context in response details/artifacts.
- Must update:
  - `intent_normaliser/docs/current_state.md`
  - `intent_normaliser/README.md`
- Verify:
  - `docker compose run --rm api pytest` (in `intent_normaliser`)

## Phase 2 Prompt
Implement only Phase 2:
- Repo: `context_api`
- Scope:
  - Extend Actions OpenAPI + instructions for research retrieval endpoints.
  - Keep read-only/retrieval usage guidance.
- Must update:
  - `context_api/adapters/chatgpt_actions/openapi.yaml`
  - `context_api/adapters/chatgpt_actions/gpt_instructions.md`
  - `context_api/docs/current_state.md`
- Verify:
  - `docker compose run --rm --build api pytest`
  - `bash scripts/edge_validate.sh`

## Phase 3 Prompt
Implement only Phase 3:
- Repo: `brain_os`
- Scope:
  - Add `context_api` + `context_research_worker` services to compose runtime.
  - Wire `intent_normaliser` defaults to internal `context_api` service URL/token envs.
  - Keep edge network model intact.
- Must update:
  - `brain_os/docker-compose.yml`
  - `brain_os/compose.edge.yml`
  - `brain_os/docs/current_state.md`
- Verify:
  - `docker compose config` (in `brain_os`)
  - `docker compose up -d context_postgres context_migrate context_api context_research_worker`
  - `docker compose ps context_postgres context_api context_research_worker`

## Phase 4 Prompt
Implement only Phase 4:
- Repo: `context_api`
- Scope:
  - Add per-source ops metrics endpoint.
  - Add observability dashboard query docs.
- Must update:
  - `context_api/app/main.py`
  - `context_api/app/storage/db.py`
  - `context_api/docs/research_observability.md`
- Verify:
  - `docker compose run --rm --build api pytest`
  - `bash scripts/edge_validate.sh`

## Phase 5 Prompt
Implement only Phase 5:
- Repo: `context_api`
- Scope:
  - Add source moderation endpoints (`enable`/`disable`).
  - Add raw payload redaction tooling + endpoint.
  - Add operator review queue endpoint.
- Must update:
  - `context_api/app/main.py`
  - `context_api/app/storage/db.py`
  - `context_api/app/research/retention.py`
  - `context_api/docs/contracts/v2_research_retrieval.md`
- Verify:
  - `docker compose run --rm --build api pytest`
  - `bash scripts/edge_validate.sh`

## Phase 6 Prompt
Implement only Phase 6:
- Repo: `context_api`
- Scope:
  - Add PDF-aware extraction path in research ingestion.
  - Add retrieval scoring blend weight env knobs for feedback tuning.
- Must update:
  - `context_api/app/research/worker.py`
  - `context_api/app/intel/fetch.py`
  - `context_api/app/research/scoring.py`
  - `context_api/README.md`
- Verify:
  - `docker compose run --rm --build api pytest`
  - `bash scripts/edge_validate.sh`
