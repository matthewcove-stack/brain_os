# Brain OS — Current State (Authoritative)

## What works
- Intent ingestion and normalisation
- Shared schema contracts
- Notion Gateway API surface
- End-to-end execution (intent_normaliser -> notion_gateway) when `EXECUTE_ACTIONS=true`
- Lambic voice intake client (`../lambic_voice_client`) for voice/text capture into the pipeline
- Phase 1 smoke test script (`.\scripts\phase1_smoke.ps1`)
- Phase 3 containerized voice services (`voice_api`, `voice_web`) in `docker-compose.yml`
- Phase 3 smoke test script (`.\scripts\phase3_smoke.ps1`)

## What is incomplete
- Context sync is manual
- No clarification UI
- CI smoke test requires secrets and is manual (workflow_dispatch only)

## Phase 1 verification
A Phase 1 implementation is considered complete only when:
- A natural-language intent creates or updates a Notion task
- Duplicate submissions are idempotent
- Errors are surfaced clearly to the user (`error.code`, `error.message`, `error.details.status_code`)
- All verification commands pass

## CI (manual)
Workflow: `.github/workflows/phase1-smoke.yml`

Required GitHub Actions secrets:
- `NOTION_API_KEY`
- `API_BEARER_TOKEN`
- `BOOTSTRAP_BEARER_TOKEN`
- `N8N_BASIC_AUTH_USER`
- `N8N_BASIC_AUTH_PASSWORD`
- `N8N_ENCRYPTION_KEY`
- `N8N_API_KEY` (optional if n8n API is enabled)
- `INTENT_SERVICE_TOKEN` (optional; defaults to `change-me`)

## Phase 1 how to run (Windows)
Prereqs:
- Ensure `notion_gateway/.env` exists (copy from `notion_gateway/.env.example`) and set `NOTION_API_KEY` and `API_BEARER_TOKEN`.
- Ensure the n8n workflows in `notion_gateway/n8n/workflows/` are imported and activated.
- Keep `GATEWAY_BEARER_TOKEN` in `docker-compose.yml` aligned with `API_BEARER_TOKEN` in `notion_gateway/.env` (defaults to `change_me_api_token`).
- If you changed `INTENT_SERVICE_TOKEN`, set `$env:INTENT_SERVICE_TOKEN` before running the smoke script.

Start services (builds containers):
```
docker compose up -d --build
```

Run the Phase 1 smoke test:
```
.\scripts\phase1_smoke.ps1
```

Expected output:
- `Phase 1 smoke test succeeded. notion_task_id=<id>`

Success means:
- The same Notion task id is returned for both requests using the same `request_id`.

## Verification
Check container status:
```
docker compose ps
```

View logs for failures:
```
docker compose logs -f intent_normaliser
docker compose logs -f notion_gateway
```

## Constraints
- Single user
- Notion is the system of record
- Reliability over cleverness

## Next phases
Targeting rapid improvements to the voice capture loop.

- Phase 1: frictionless capture defaults (implemented)
- Phase 2: task lifecycle from voice (status update intents + task resolution)
- Phase 3: URL + file capture (MVP)

See `docs/phases.md` and `docs/phase_plans/*`.

## Phase Progress Log
- 2026-02-17 — Phase 1 implemented:
  - `lambic_voice_client`: added `auto` destination and made it default.
  - `intent_normaliser`: deterministic auto inference for shopping/task/note when destination is omitted; weak matches return clarification choices.
  - `intent_normaliser`: task create defaults `status` to `Todo`.
  - `notion_gateway`: task create workflow enforces `Status = Todo` if missing.
  - Verification:
    - `docker compose build voice_web` passes.
    - `docker compose exec -T intent_normaliser pytest -q tests/test_api.py -k "auto_infers or list_target_routes_to_list_add_item_action or notes_target_routes_to_note_capture_action"` passes.
